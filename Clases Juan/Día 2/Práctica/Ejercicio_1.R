# Cargar datos
df <- read.csv("data/season-1819_csv.csv")

# Función para construir tabla de victorias
build_win_table <- function(team, data) {
  # Partidos en casa y fuera
  home_games <- subset(data, HomeTeam == team)
  away_games <- subset(data, AwayTeam == team)
  
  # Victorias
  home_wins <- sum(home_games$FTR == "H")
  away_wins <- sum(away_games$FTR == "A")
  
  # No victorias
  home_no_wins <- nrow(home_games) - home_wins
  away_no_wins <- nrow(away_games) - away_wins
  
  # Tabla (filas: Home/Away, columnas: Win/No win)
  table <- matrix(c(home_wins, home_no_wins,
                    away_wins, away_no_wins),
                  nrow = 2, byrow = TRUE)
  colnames(table) <- c("Win", "No win")
  rownames(table) <- c("Home", "Away")
  
  return(table)
}

# Tablas
sociedad_table <- build_win_table("Sociedad", df)
barcelona_table <- build_win_table("Barcelona", df)

cat("Tabla Real Sociedad:\n")
print(sociedad_table)

cat("\nTabla Barcelona:\n")
print(barcelona_table)

# Test Fisher para Real Sociedad
sociedad_fisher <- fisher.test(sociedad_table)
cat("\nFisher test Real Sociedad:\n")
print(sociedad_fisher)

if (sociedad_fisher$p.value < 0.05) {
  cat("Independencia: FALSE (hay asociación significativa)\n")
} else {
  cat("Independencia: TRUE (no hay asociación)\n")
}

# Test Fisher para Barcelona
barcelona_fisher <- fisher.test(barcelona_table)
cat("\nFisher test Barcelona:\n")
print(barcelona_fisher)

if (barcelona_fisher$p.value < 0.05) {
  cat("Independencia: FALSE (hay asociación significativa)\n")
} else {
  cat("Independencia: TRUE (no hay asociación)\n")
}
