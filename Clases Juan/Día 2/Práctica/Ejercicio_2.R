# 1. Leer el fichero
crime <- read.csv("data/crimeUS.csv")

# Ver estructura de datos
str(crime)
head(crime)

# ---------------------------------------------------
# 2. Calcular la media de porcentajes de población
#    afroamericana y caucásica por estado
# ---------------------------------------------------
mean_pop <- aggregate(cbind(afam, cauc) ~ state, 
                      data = crime, 
                      FUN = mean)

# Redondear (quitar decimales)
mean_pop$afam <- round(mean_pop$afam)
mean_pop$cauc <- round(mean_pop$cauc)

print(mean_pop)

# ---------------------------------------------------
# 3. Tabla de contingencia para District of Columbia y Hawaii
# ---------------------------------------------------
subset_states <- subset(crime, state %in% c("District of Columbia", "Hawaii"))

# Construir tabla: filas = estados, columnas = poblaciones
table_dc_hi <- as.table(as.matrix(
  aggregate(cbind(afam, cauc) ~ state, 
            data = subset_states, sum)[, -1]
))
rownames(table_dc_hi) <- c("District of Columbia", "Hawaii")

print(table_dc_hi)

# Test de Fisher (mejor que chi-cuadrado para 2x2)
test_dc_hi <- fisher.test(table_dc_hi)
print(test_dc_hi)

# ---------------------------------------------------
# 4. Repetir para Florida y Hawaii
# ---------------------------------------------------
subset_states2 <- subset(crime, state %in% c("Florida", "Hawaii"))

table_fl_hi <- as.table(as.matrix(
  aggregate(cbind(afam, cauc) ~ state, 
            data = subset_states2, sum)[, -1]
))
rownames(table_fl_hi) <- c("Florida", "Hawaii")

print(table_fl_hi)

test_fl_hi <- fisher.test(table_fl_hi)
print(test_fl_hi)
