library(dplyr)
library(ggplot2)
library(viridis)

## Exercise 1 - NBA Stats #####

# Minutes played vs points

data <- read.csv("C:/Users/enriq/Desktop/Master/Data Science (MIB)/Clases Rafa/data/NBA/Seasons_Stats.csv", header = T, sep = ",")

data1 <- data %>%
  filter(Year == 1970) %>%
  select(Player, MP, PTS)

ggplot(data1, aes(x = MP, y = PTS)) +
  geom_point() +
  theme_minimal()

# Correlation

pearson <- cor(data1$MP,data1$PTS,method = "pearson")
spearman <- cor(data1$MP,data1$PTS,method = "spearman")

pearson
spearman

cor.test(data1$MP,data1$PTS,method = "pearson")
cor.test(data1$MP,data1$PTS,method = "spearman")


## Exercise 2 - Cars #####

# Car Weight vs Fuel Efficiency

data <- read.csv("C:/Users/enriq/Desktop/Master/Data Science (MIB)/Clases Rafa/data/auto-mpg.csv", header = T, sep = ",")

data1 <- data %>%
  select(mpg,weight)

ggplot(data1, aes(x = weight, y = mpg)) +
  geom_point(alpha = 0.5) +
  theme_minimal()

data1$mpg <- log2(data1$mpg)

Fig1 <- ggplot(data1, aes(x = weight, y = mpg)) +
  geom_point(alpha = 0.5) +
  theme_minimal()

Fig3 <- ggplot(data1, aes(weight)) +
  geom_histogram(bins = 20, fill = "orange", color = "white") +
  theme_minimal() +
  labs(title = "Distribución del peso")

Fig4 <- ggplot(data1, aes(mpg)) +
  geom_histogram(bins = 20, fill = "steelblue", color = "white") +
  theme_minimal() +
  labs(title = "Distribución de la eficiencia del combustible")

# Correleción

pearson <- cor(data1$weight, data1$mpg, method = "pearson")
spearman <- cor(data1$weight, data1$mpg, method = "spearman")

Fig2 <- ggplot(data1, aes(x = weight, y = mpg)) +
  geom_point(alpha = 0.5) +
  theme_minimal() +
  geom_smooth(method = "lm", color = "red", linetype = "dashed")

ggarrange(Fig1, Fig2, Fig3, Fig4)  

lm(mpg ~ weight, data = data1)  
