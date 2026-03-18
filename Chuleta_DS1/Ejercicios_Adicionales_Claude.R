rm(list = ls())

library(ggplot2)
library(viridis)
library(dplyr)
library(tidyr)
library(stringr)
library(pwr)
library(corrplot)

# Ejercicio 5: Análisis de Calidad del Aire #####

# Vamos a trabajar con datos de calidad del aire en diferentes ciudades. 
# Este dataset contiene mediciones de contaminantes (PM2.5, PM10, NO2, CO) 
# en varias ciudades durante 2023-2024.

data(airquality)

ciudades <- c("Madrid", "Barcelona", "Valencia", "Sevilla", "Bilbao")

df_air <- bind_rows(lapply(ciudades, function(city) {
  df_temp <- airquality
  df_temp$City <- city
  # Añadir algo de variabilidad por ciudad (opcional pero más realista)
  df_temp$Ozone <- df_temp$Ozone + rnorm(nrow(df_temp), mean = runif(1, -10, 10), sd = 3)
  df_temp$Temp <- df_temp$Temp + rnorm(nrow(df_temp), mean = runif(1, -5, 5), sd = 2)
  return(df_temp)
}))

# Asegurar que Ozone no sea negativo
df_air$Ozone <- pmax(0, df_air$Ozone)


## 5.1 (1.5 puntos) #####

# Generar un heatmap que muestre la concentración promedio de Ozono (Ozone) por mes y ciudad. 
# Usa scale_fill_viridis() para los colores. La gráfica debe permitir identificar rápidamente 
# qué ciudades y meses tienen mayor contaminación.
# Pista: Agrupa por Month y City, calcula la media de Ozone (eliminando NAs), y usa geom_tile().

library(ggplot2)
library(dplyr)
library(viridis)

# Preparar datos
df_heatmap <- df_air %>%
  filter(!is.na(Ozone)) %>%
  group_by(Month, City) %>%
  summarise(Ozone_promedio = mean(Ozone, na.rm = TRUE), .groups = "drop") %>%
  mutate(Mes = factor(Month, 
                      levels = 5:9,
                      labels = c("Mayo", "Junio", "Julio", "Agosto", "Septiembre")))

# Crear heatmap CORRECTO
ggplot(df_heatmap, aes(x = City, y = Mes, fill = Ozone_promedio)) +
  geom_tile(color = "white", linewidth = 0.5) +
  scale_fill_viridis(option = "plasma", 
                     name = "Concentración\npromedio de\nOzono (ppb)") +
  labs(title = "Concentración promedio de Ozono por ciudad y mes",
       x = "Ciudad",
       y = "Mes") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5, face = "bold"),
        panel.grid = element_blank()) +
  geom_text(aes(label = round(Ozone_promedio, 1)), 
            color = "white", size = 3.5, fontface = "bold")



## 5.2 (2 puntos) #####
# Para cada ciudad, calcular la correlación entre la temperatura (Temp) y los niveles de ozono (Ozone). 
# Realizar el test de correlación de Pearson y ajustar los p-valores usando el método de Bonferroni.
# Crear una gráfica de barras que muestre:
  # En el eje X: las ciudades
  # En el eje Y: el coeficiente de correlación
  # Color de las barras: significativo (p-valor ajustado < 0.05) vs no significativo


data1 <- df_air %>%
  filter(!is.na(Ozone)) %>%
  group_by(City) %>%
  summarise(correlación = cor(Temp, Ozone, method = "pearson"),
            p_value = cor.test(Temp, Ozone)$p.value,
            .groups = "drop")

data1 <- data1 %>%
  mutate(p_ajustado = p.adjust(p_value, method = "bonferroni"))

data1 <- data1 %>%
  mutate(significativo = p_ajustado < 0.05)

ggplot(data1, aes(x = City, y = correlación, fill = significativo)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.7, vjust = 0.7)) +
  labs(x = "Ciudad", y = "Correlación", fill = "¿Significativo?",
       title = "Correlación entre la temperatura y los niveles de ozono de las ciudades")


##5.3 (1.5 puntos)#####

#Se sospecha que los días con viento fuerte (Wind > 10) tienen menores niveles de contaminación. 
#Para cada ciudad, realizar un test estadístico apropiado para comparar los niveles de ozono en días con viento fuerte 
#vs días con viento moderado/bajo.
#Crear una tabla con los resultados (ciudad, p-valor, conclusión).  


data2 <- df_air %>%
  filter(!is.na(Ozone))

data2$Nivel_viento <- ifelse(data2$Wind > 10, "Fuerte", "Moderado")

ciudades <- unique(data2$City)

p_value <- vector()

diferencia <- vector()

for(i in 1:length(ciudades)){
  ciudad <- ciudades[i]
  datos <- data2[data2$City == ciudad,]
  
  test <- t.test(Ozone ~ Nivel_viento, data = datos)
  p_value[i] <- test$p.value
  diferencia[i] <- test$estimate[2] - test$estimate[1]
}

resultados <- data.frame(ciudad = ciudades, p_value = p_value, 
                         conclusión = ifelse(p_value < 0.05 & diferencia > 0, "Se confirma sospecha", "No se confirma sospecha"))

head(resultados)


## 5.4 (2 puntos) ######

#Realizar un análisis de componentes principales (PCA) usando las variables Ozone, Solar.R, Wind y Temp (después de eliminar NAs y normalizar).
#Crear un biplot que muestre los dos primeros componentes principales, coloreando los puntos por ciudad.
#¿Qué variables contribuyen más al PC1 y PC2?
#¿Se pueden distinguir patrones de contaminación por ciudad?


data3 <- df_air %>%
  select(City, Ozone, Solar.R, Wind, Temp) %>%
  na.omit()

PCA <- prcomp(data3[, -1], center = T, scale. = T)

summary(PCA)

pca <- data.frame(PC1 = PCA$x[,1],
                  PC2 = PCA$x[,2],
                  Ciudad = data3$City)

ggplot(pca, aes(x = PC1, y = PC2, color = Ciudad)) +
  geom_point(size = 2, alpha = 0.7) +
  stat_ellipse(type = "norm", level = 0.68) +
  labs(title = "PCA de variables ambientales")
  theme_minimal()

round(PCA$rotation[, 1:2], 3)


## 5.5 (2 puntos)#####

#Se quiere predecir si un día tendrá "Alta contaminación" (Ozone > 80) basándose en la temperatura.
#Crear una variable categórica AltaContaminacion (TRUE si Ozone > 80)
#Para cada ciudad, calcular el tamaño de muestra necesario para detectar una diferencia en temperatura de
#5°F entre días de alta y baja contaminación, asumiendo:
  
#Desviación estándar: 10°F
#Alpha: 0.05
#Power: 0.80

#¿Alguna ciudad tiene suficientes observaciones?



data4 <- df_air %>%
  mutate(AltaContaminacion = Ozone > 80)

# Parámetros fijos
diff <- 5
sd <- 10
alpha <- 0.05
power <- 0.80

# Filtrar datos válidos
df_filtrado <- data4 %>%
  filter(!is.na(Ozone), !is.na(Temp))

# Calcular tamaño muestral por ciudad
resultados <- df_filtrado %>%
  group_by(City) %>%
  summarise(
    n_alta = sum(AltaContaminacion),
    n_baja = sum(!AltaContaminacion),
    total = n(),
    muestra_necesaria = ceiling(2 * pwr.t.test(d = diff/sd, sig.level = alpha, power = power, type = "two.sample")$n),
    suficiente = total >= muestra_necesaria,
    .groups = "drop"
  )

resultados





