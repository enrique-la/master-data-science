library(ggplot2)
library(viridis)
library(ggrepel)
library(dplyr)
library(tm)
library(textstem)
library(pwr)
library(tidyr)
library(stringr)
library(ggpubr)

estadisticas <- read.csv("./data/players_data-2024_2025.csv")
jugadores <- read.csv("./data/players.csv")
valor <- read.csv("./data/player_valuations.csv")

valor$date <- sapply(strsplit(valor$date, "-"), `[`, 1)
valor$date <- as.numeric(valor$date)

valor_jugador <- merge(valor, jugadores, by = "player_id", all.x = TRUE)

valor_jugador <- valor_jugador %>%
  group_by(player_id) %>%
  arrange(desc(date), .by_group = TRUE) %>%
  slice_head(n = 1) %>%
  ungroup() %>%
  arrange(desc(market_value_in_eur.x)) %>%
  filter(player_club_domestic_competition_id %in% c("GB1", "ES1", "IT1", "L1", "FR1"))


estadisticas <- estadisticas %>%
  group_by(Player) %>%
  arrange(desc(Rk), .by_group = TRUE) %>%
  slice_head(n = 1) %>%
  ungroup()


# --- Limpiar nombres de estadisticas ---
estadisticas <- estadisticas %>%
  mutate(name = tolower(iconv(Player, from = "UTF-8", to = "ASCII//TRANSLIT")))

# --- Limpiar nombres de valor_jugador y quedarnos con un valor por jugador ---
valor_jugador_unique <- valor_jugador %>%
  mutate(name_clean = tolower(iconv(name, from = "UTF-8", to = "ASCII//TRANSLIT"))) %>%
  group_by(name_clean) %>%
  # Tomar máximo valor de mercado por jugador
  slice_max(market_value_in_eur.x, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(name_clean, market_value_in_eur.x)

# --- Unir al dataset de estadisticas ---
estadisticas <- estadisticas %>%
  left_join(valor_jugador_unique, by = c("name" = "name_clean")) %>%
  rename(market_value = market_value_in_eur.x) %>%
  arrange(desc(market_value))










# Ver jugadores ordenados por valor de mercado
estadisticas %>%
  filter(Age >=38) %>%
  arrange(desc(market_value)) %>%
  select(Player, market_value, Pos, Age, Squad) %>%
  print(n = 20000)






# ==============================
# 1️⃣ t-test: KP entre MF y FW
# ==============================
t_test_data <- estadisticas %>%
  filter(Pos %in% c("MF","FW"), !is.na(KP))

t_test_result <- t.test(KP ~ Pos, data = t_test_data)
print(t_test_result)

# Gráfico t-test
ggplot(t_test_data, aes(x=Pos, y=KP, fill=Pos)) +
  geom_boxplot(alpha=0.7) +
  geom_jitter(width=0.2, alpha=0.4) +
  theme_minimal() +
  scale_fill_viridis(discrete=TRUE) +
  labs(title="t-test: Key Passes MF vs FW",
       subtitle="Comparación de KP entre centrocampistas y delanteros")

# ==============================
# 2️⃣ ANOVA: Market value por posición DF/MF/FW
# ==============================
anova_data <- estadisticas %>%
  filter(Pos %in% c("DF","MF","FW"), !is.na(market_value))

anova_result <- aov(market_value ~ Pos, data = anova_data)
summary(anova_result)

# Gráfico ANOVA
ggplot(anova_data, aes(x=Pos, y=market_value, fill=Pos)) +
  geom_boxplot(alpha=0.7) +
  geom_jitter(width=0.2, alpha=0.4) +
  scale_y_continuous(labels=scales::dollar_format()) +
  scale_fill_viridis(discrete=TRUE) +
  theme_minimal() +
  labs(title="ANOVA: Market Value por posición",
       subtitle="DF vs MF vs FW")

# ==============================
# 3️⃣ Fisher exact test: GK vs CS>10
# ==============================
fisher_data <- estadisticas %>%
  mutate(GK_flag = ifelse(Pos=="GK", "GK","NoGK"),
         CS_flag = ifelse(!is.na(CS) & CS>10, "HighCS","LowCS")) %>%
  filter(!is.na(CS_flag))

fisher_table <- table(fisher_data$GK_flag, fisher_data$CS_flag)
fisher_result <- fisher.test(fisher_table)
print(fisher_result)

# Gráfico Fisher
ggplot(fisher_data, aes(x=GK_flag, fill=CS_flag)) +
  geom_bar(position="fill") +
  scale_y_continuous(labels=scales::percent) +
  scale_fill_viridis(discrete=TRUE) +
  theme_minimal() +
  labs(title="Fisher Test: GK vs Clean Sheets >10",
       y="Proporción")

# ==============================
# 4️⃣ Correlación xG vs Gls (FW)
# ==============================
cor_data <- estadisticas %>%
  filter(Pos=="FW", !is.na(xG), !is.na(Gls))

cor_result <- cor.test(cor_data$xG, cor_data$Gls)
print(cor_result)

# Gráfico correlación
ggplot(cor_data, aes(x=xG, y=Gls)) +
  geom_point(aes(color=market_value), alpha=0.7) +
  scale_color_viridis(option="plasma") +
  geom_smooth(method="lm", color="red") +
  theme_minimal() +
  labs(title="Correlación xG vs Gls en delanteros",
       color="Market Value (€)")

# ==============================
# 5️⃣ PCA: stats ofensivas para scoring
# ==============================
off_vars <- c("Gls","Ast","KP","Carries","Sh","SoT") 
pca_data <- estadisticas %>%
  select(all_of(off_vars)) %>%
  drop_na() %>%
  scale()

pca_res <- prcomp(pca_data)
fviz_pca_biplot(pca_res, repel=TRUE,
                col.ind="cos2", gradient.cols=c("#00AFBB", "#E7B800", "#FC4E07"))

# ==============================
# 6️⃣ LM: predecir market_value
# ==============================
lm_data <- estadisticas %>%
  select(market_value, Gls, Ast, KP, Recov) %>%
  drop_na()

lm_model <- lm(market_value ~ ., data=lm_data)
summary(lm_model)

# Gráfico LM
ggplot(lm_data, aes(x=Gls, y=market_value)) +
  geom_point(aes(color=Ast), alpha=0.7) +
  geom_smooth(method="lm", se=TRUE, color="red") +
  scale_color_viridis() +
  theme_minimal() +
  labs(title="LM: Market Value vs Gls + Ast")

# ==============================
# 7️⃣ GLM binomial: Probabilidad de chollo
# ==============================
# Definir chollo como market_value < valor predicho por LM
lm_data$predicted <- predict(lm_model, lm_data)
lm_data$chollo <- ifelse(lm_data$market_value < lm_data$predicted, 1, 0)

glm_model <- glm(chollo ~ Gls + Ast + KP + Recov, data=lm_data, family=binomial)
summary(glm_model)

# Gráfico GLM
ggplot(lm_data, aes(x=predicted, y=chollo)) +
  geom_jitter(height=0.05, alpha=0.6, aes(color=KP)) +
  scale_color_viridis() +
  theme_minimal() +
  labs(title="GLM: Probabilidad de chollo",
       y="Chollo (1=Sí,0=No)", x="Valor predicho (€)")
