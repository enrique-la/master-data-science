# 1. Leer el archivo CSV
crime_data <- read.csv("data/crimeUS.csv")

# 2. Transformar los crímenes violentos a casos por 100,000 habitantes
crime_data$violent_rate <- (crime_data$violent / crime_data$population) * 100000

# 3. Comparar violent crimes entre Alaska, Georgia y Missouri usando ANOVA
subset1 <- subset(crime_data, state %in% c("Alaska", "Georgia", "Missouri"))

anova1 <- aov(violent_rate ~ state, data = subset1)
summary(anova1)  # Esto mostrará si hay diferencias significativas

# 4. Comparar ahora District of Columbia, Hawaii y Idaho
subset2 <- subset(crime_data, state %in% c("District of Columbia", "Hawaii", "Idaho"))

anova2 <- aov(violent_rate ~ state, data = subset2)
summary(anova2)

# Dibujar un boxplot para visualizar las diferencias
boxplot(violent_rate ~ state, data = subset2,
        main = "Violent Crime Rate per 100,000 Citizens",
        xlab = "State",
        ylab = "Violent Crimes per 100,000",
        col = c("lightblue", "lightgreen", "lightpink"))
