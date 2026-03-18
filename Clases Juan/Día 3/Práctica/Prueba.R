library(ggplot2)
library(viridis)
library(stringr)

## Ejercicio 1 (Repaso) #####
# Generar un heatmap con el número de robos por año y estado cargando crimeUS.csv

data <- read.csv("C:/Users/enriq/Desktop/Master/Data Science (MIB)/Clases Juan/Día 3/data/crimeUS (1).csv", header = T, sep = ",")

robos <- data %>%
  group_by(as.factor(year), state) %>%
  summarise(robos = sum(robbery)) %>%
  setNames(c("año","estado","robos"))
head(robos)

Fig1 <- ggplot(robos, aes(x = estado, y = año, fill = robos)) +
  geom_tile() + 
  theme_minimal() +
  scale_fill_viridis() + 
  labs(title = "Número de robos por año y estado", x = "estado", y = "año") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0, size = 8))
Fig1


### Ejemplos Diapositivas PCA #####
## Ejercicio 1 - Error en componentes #####

data <- read.csv("C:/Users/enriq/Desktop/Master/Data Science (MIB)/Clases Juan/Día 3/data/componentes.csv", header = T, sep = ",")

X <- data[1:14]
tipo <- data$type

PCA <- prcomp(X, scale = T)
summary(PCA)

cat("Como podemos comprobar, PC1 tiene una energía de 0.7748 y PC2 de 0.1575 lo que contribuyen en total un 0.9323 de la energía total")

pc1 <- PCA$x[,1]
pc2 <- PCA$x[,2]

datos_PCA <- data.frame(PC1 = pc1, PC2 = pc2, Tipo = tipo)

ggplot(datos_PCA, aes(x = PC1, y = PC2, color = Tipo)) +
  geom_point() +
  theme_minimal()


## Ejercicio 2 - Football #####

data <- read.csv("C:/Users/enriq/Desktop/Master/Data Science (MIB)/Clases Juan/Día 3/data/FIFA (1).txt", header = T, sep = ",")

data1 <- data %>%
  select(Acceleration:Volleys, Preferred.Positions) %>%
  mutate(across(Acceleration:Volleys, as.numeric)) %>%
  na.omit()

Position <- str_split(data1$Preferred.Positions, " ") %>%
  sapply(function(x) x[1])
data1$Preferred.Positions <- Position



Estadísticas <- select(data1, Acceleration:Volleys)
Posición <- Position

PCA <- prcomp(Estadísticas, scale = F)
summary(PCA)

pc1 <- PCA$x[,1]
pc2 <- PCA$x[,2]

datos_PCA <- data.frame(PC1 = pc1, PC2 = pc2, Posición = Posición)

ggplot(datos_PCA, aes(x = PC1, y = PC2, color = Posición)) +
  geom_point(size = 2, alpha = 0.8) +
  theme_minimal()





