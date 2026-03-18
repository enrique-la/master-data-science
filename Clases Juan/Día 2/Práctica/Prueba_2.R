data <- read.csv("C:/Users/enriq/Desktop/Uni/Data Science (MIB)/Clases Juan/Día 2/data/crimeUS.csv", header = T, sep = ",")

data1 <- data %>%
  aggregate(cbind(afam, cauc) ~ state, FUN = mean)

data1$afam <- round(data1$afam)
data1$cauc <- round(data1$cauc)


data2 <- data %>%
  group_by(state) %>%
  summarise(African_American = round(mean(afam)),
            Caucasic = round(mean(cauc)))

head(data2)
head(data1)




crear_tabla <- function(estado1, estado2, datos) {
  
  V1 <- datos %>%
    filter(state == estado1) %>%
    pull(cauc) %>%
    sum()
  V2 <- datos %>%
    filter(state == estado1) %>%
  pull(afam) %>%
    sum()
  V3 <- datos %>%
    filter(state == estado2) %>%
  pull(cauc) %>%
    sum()
  V4 <- datos %>%
    filter(state == estado2) %>%
  pull(afam) %>%
    sum()
  
  tabla <- matrix(nrow = 2, ncol = 2)
  tabla[1,1] <- V1
  tabla[1,2] <- V2
  tabla[2,1] <- V3
  tabla[2,2] <- V4
  
  colnames(tabla) <- c("cauc","afam")
  rownames(tabla) <- c(estado1, estado2)
  
  return(tabla)
}

tabla1 <- crear_tabla("District of Columbia","Hawaii",data)
tabla1
fisher.test(tabla1)

tabla2 <- crear_tabla("Florida","Hawaii",data)
tabla2
fisher.test(tabla2)
