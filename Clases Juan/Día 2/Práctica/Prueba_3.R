library(ggplot2)

data <- read.csv("C:/Users/enriq/Desktop/Uni/Data Science (MIB)/Clases Juan/Día 2/data/crimeUS.csv", header = T, sep = ",")

data1 <- data %>%
  mutate(violent_crimes = (violent/population)*100000)

comparar <- function(s1, s2, s3, data) {
data2 <- data %>%
  group_by(state) %>%
  filter(state %in% c(s1, s2, s3))

modelo <- aov(data2$violent_crimes ~ data2$state)
summary(modelo)

bp <- ggplot(data2, aes(x = state, y = violent_crimes)) + 
  geom_boxplot(color = "blue", fill = "blue", alpha = 0.3) +
  theme_minimal()
bp

#return(summary(modelo))
return(bp)
}

comp1 <- comparar("Alaska","Georgia","Missouri", data1)
comp1

comp2 <- comparar("District of Columbia","Hawaii","Idaho", data1)
comp2
