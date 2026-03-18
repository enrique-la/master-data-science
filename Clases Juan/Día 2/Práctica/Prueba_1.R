library(dplyr)

datos<- read.csv("C:/Users/enriq/Desktop/Uni/Data Science (MIB)/Clases Juan/Día 2/data/season-1819_csv.csv", header = T, sep = ",")

construir_tabla <- function(datos,equipo) {
  win_home <- datos %>%
    filter(HomeTeam == equipo & FTR == "H")
  win_home <- nrow(win_home)
  no_win_home <- datos %>%
    filter(HomeTeam == equipo & FTR != "H")
  no_win_home <- nrow(no_win_home)
  win_away <- datos %>%
    filter(AwayTeam == equipo & FTR == "A")
  win_away <- nrow(win_away)
  no_win_away <- datos %>%
    filter(AwayTeam == equipo & FTR != "A")
  no_win_away <- nrow(no_win_away)
  
  tabla <- matrix(nrow = 2, ncol = 2)
  tabla[1,1] <- win_home
  tabla[1,2] <- win_away
  tabla[2,1] <- no_win_home
  tabla[2,2] <- no_win_away
  
  colnames(tabla) <- c("Home","Away")
  rownames(tabla) <- c("Win", "No Win")
  
  return(tabla)
}

tabla_real <- construir_tabla(datos,"Sociedad")
tabla_real
fisher.test(tabla_real)

tabla_barsa <- construir_tabla(datos,"Barcelona")
tabla_barsa
fisher.test(tabla_barsa)

cat("En resumen, ni el Barça ni la Real Sociedad dependen de estar en casa para ganar")
