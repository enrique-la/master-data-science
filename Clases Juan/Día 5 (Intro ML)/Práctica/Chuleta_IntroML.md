# Chuleta de Introducción a Machine Learning

## 1. LIBRERÍAS PRINCIPALES

```python
import numpy as np
import matplotlib.pyplot as plt
from random import sample
from sklearn.metrics import matthews_corrcoef, metrics
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
import pylab as pl
```

---

## 2. MÉTRICAS DE REGRESIÓN

### 2.1 MSE (Mean Squared Error)
**Concepto:** Mide el error cuadrático medio entre valores reales y predicciones.

**Fórmula:** `MSE = Σ(y - pred)² / n`

**Código:**
```python
MSE = sum((y - pred)**2)/n
```

**Interpretación:**
- Valores más bajos = mejor modelo
- Penaliza más los errores grandes (al elevar al cuadrado)
- Mismas unidades que la variable al cuadrado

---

### 2.2 Coeficiente de Correlación
**Concepto:** Mide la relación lineal entre dos variables (rango: -1 a 1).

**Código:**
```python
cor = np.corrcoef(y, pred)
correlation_value = cor[0,1]  # Matriz de correlación, tomar elemento [0,1]
```

**Interpretación:**
- 1 = correlación positiva perfecta
- 0 = sin correlación lineal
- -1 = correlación negativa perfecta
- Valores > 0.7 o < -0.7 = correlación fuerte

**Visualización:**
```python
plt.scatter(y, pred)
plt.xlabel('y')
plt.ylabel('pred')
plt.title('y vs pred\nMSE={:.2f}, cor={:.2f}'.format(MSE, cor[0,1]))
plt.plot([y.min(), y.max()], [y.min(), y.max()], 'k--')  # Línea diagonal de referencia
plt.show()
```

---

## 3. MÉTRICAS DE CLASIFICACIÓN

### 3.1 Accuracy (Exactitud)
**Concepto:** Proporción de predicciones correctas sobre el total.

**Fórmula:** `Accuracy = (TP + TN) / (TP + TN + FP + FN)`

**Código:**
```python
acc = sum(actual == pred) / n
```

**Limitaciones:**
- No funciona bien con clases desbalanceadas
- Puede ser engañoso en datasets con clases muy desiguales

---

### 3.2 Matthews Correlation Coefficient (MCC)
**Concepto:** Métrica balanceada para clasificación binaria, incluso con clases desbalanceadas.

**Fórmula:** `MCC = (TP×TN - FP×FN) / √((TP+FP)(TP+FN)(TN+FP)(TN+FN))`

**Código:**
```python
from sklearn.metrics import matthews_corrcoef
MC = matthews_corrcoef(actual, pred)
```

**Interpretación:**
- Rango: -1 a 1
- 1 = predicción perfecta
- 0 = predicción aleatoria
- -1 = desacuerdo total
- Más robusto que accuracy con clases desbalanceadas

**Ejemplo de uso:**
```python
n = 1000  # total de muestras
p = 100   # positivos reales
L = 50    # positivos predichos

actual = np.repeat(0, n)
pred = np.repeat(0, n)
actual[0:p] = 1

idx = list(np.linspace(1, (p + L), (p + L), dtype=int))
idx = sample(idx, L)
pred[idx] = 1

acc = sum(actual == pred) / n
MC = matthews_corrcoef(actual, pred)
```

---

## 4. CURVA ROC (Receiver Operating Characteristic)

### Conceptos clave:
- **TPR (True Positive Rate / Recall / Sensitivity):** TP / (TP + FN)
- **FPR (False Positive Rate):** FP / (FP + TN)
- **AUC (Area Under Curve):** Área bajo la curva ROC

### Código completo:
```python
from sklearn import metrics

# Generar datos de ejemplo
n = 100
labels = np.repeat(0, n)  # etiquetas reales
scores = np.random.normal(0, 1, n)  # puntuaciones del modelo

# Calcular curva ROC
fpr, tpr, thresholds = metrics.roc_curve(labels, scores)
roc_auc = metrics.auc(fpr, tpr)

# Visualizar
pl.clf()
pl.plot(fpr, tpr, label='ROC curve')
pl.xlabel('FPR')
pl.ylabel('TPR')
pl.title('ROC curve : AUC=%0.2f' % roc_auc)
pl.ylim([0.0, 1.05])
pl.xlim([0.0, 1.0])
pl.show()
```

### Interpretación:
- **AUC = 1.0:** Clasificador perfecto
- **AUC = 0.5:** Clasificador aleatorio (línea diagonal)
- **AUC < 0.5:** Peor que aleatorio
- **AUC > 0.7:** Generalmente considerado bueno

---

## 5. CURVA PRECISION-RECALL

### Conceptos clave:
- **Precision:** TP / (TP + FP) - De los que predije positivos, cuántos acerté
- **Recall:** TP / (TP + FN) - De los positivos reales, cuántos detecté

### Código completo:
```python
precision, recall, thresholds = metrics.precision_recall_curve(labels, scores)
area = metrics.auc(recall, precision)

pl.clf()
pl.plot(recall, precision, label='Precision-Recall curve')
pl.xlabel('Recall')
pl.ylabel('Precision')
pl.title('Precision-Recall : AUC=%0.2f' % area)
pl.ylim([0.0, 1.05])
pl.xlim([0.0, 1.0])
pl.show()
```

### Cuándo usar:
- **ROC:** Cuando las clases están balanceadas
- **Precision-Recall:** Cuando hay desbalance de clases (especialmente si la clase positiva es minoritaria)

---

## 6. BIAS-VARIANCE TRADEOFF

### Conceptos:
- **Bias (Sesgo):** Error por simplificaciones incorrectas del modelo
  - Alto bias = underfitting
  - El modelo es demasiado simple

- **Variance (Varianza):** Error por sensibilidad a pequeñas fluctuaciones en los datos de entrenamiento
  - Alta varianza = overfitting
  - El modelo es demasiado complejo

### Generación de datos sintéticos:
```python
np.random.seed(123)
random.seed(123)

# Datos con patrón polinómico + ruido
x = np.arange(0, 5.1, 0.1)
x = np.repeat(x, 3)
y = 0 + 2*x - 7.5*x**2 + 1.5*x**3 + np.random.normal(0, 4, len(x))

# Función verdadera (sin ruido)
true_y = 0 + 2*x - 7.5*x**2 + 1.5*x**3
```

### Visualización básica:
```python
plt.figure(figsize=(10, 6))
plt.scatter(x, y, s=20, alpha=0.7)
plt.plot(x, true_y, 'r-', linewidth=2, label='True function')
plt.xlabel('x')
plt.ylabel('y')
plt.title('Original Data')
plt.legend()
plt.tight_layout()
plt.show()
```

### Modelo simple (High Bias):
```python
# Predicción por media (modelo muy simple)
iix_test = random.sample(range(len(x)), 100)
my_prediction = np.mean(y[iix_test])
plt.axhline(y=my_prediction, color='#0000AA', linewidth=2, label='Mean prediction')
```

---

## 7. REGRESIÓN POLINÓMICA

### 7.1 Conceptos básicos
Transforma características simples en polinomios para capturar relaciones no lineales.

### 7.2 Implementación completa

```python
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression

# Preparar datos de entrenamiento
iix_train = random.sample(range(len(x)), 100)
x_train = x[iix_train]
y_train = y[iix_train]

# Ordenar por x
sorted_idx = np.argsort(x_train)
x_train_sorted = x_train[sorted_idx]
y_train_sorted = y_train[sorted_idx]

# Crear características polinómicas
poly_features = PolynomialFeatures(degree=3)
x_poly = poly_features.fit_transform(x_train_sorted.reshape(-1, 1))

# Entrenar modelo
modelo = LinearRegression()
modelo.fit(x_poly, y_train_sorted)

# Hacer predicciones
x_curva = np.linspace(x.min(), x.max(), 300)
x_curva_reshaped = x_curva.reshape(-1, 1)
x_curva_poly = poly_features.transform(x_curva_reshaped)
y_predicha = modelo.predict(x_curva_poly)

# Obtener parámetros del modelo
coeficientes = modelo.coef_
intercepto = modelo.intercept_
```

### 7.3 Visualización
```python
plt.figure(figsize=(10, 6))
plt.scatter(x, y, color='blue', s=100, alpha=0.6, label='Datos originales', zorder=3)
plt.plot(x_curva, y_predicha, color='#AA0000', linewidth=2, label='Polinomio de grado 3', zorder=2)
plt.xlabel('X', fontsize=12)
plt.ylabel('Y', fontsize=12)
plt.title('Regresión Polinómica de Grado 3', fontsize=14, fontweight='bold')
plt.legend(fontsize=10)
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()
```

### 7.4 Comparación de grados polinómicos

**Grado 3 (Apropiado):**
```python
poly_features = PolynomialFeatures(degree=3)
# Balancea bias y varianza
# Captura la tendencia real sin sobreajustar
```

**Grado 10 (Overfitting):**
```python
poly_features = PolynomialFeatures(degree=10)
# Alta varianza, bajo bias
# Se ajusta demasiado al ruido de los datos de entrenamiento
# Diferentes muestras dan curvas muy diferentes
```

---

## 8. FUNCIONES ÚTILES DE NUMPY Y MATPLOTLIB

### NumPy:
```python
np.linspace(start, stop, n)          # n puntos equiespaciados entre start y stop
np.repeat(value, n)                  # Repetir value n veces
np.random.normal(mean, std, size)    # Generar datos con distribución normal
np.argsort(array)                    # Índices que ordenarían el array
np.arange(start, stop, step)         # Array con valores de start a stop con paso step
array.reshape(-1, 1)                 # Transformar a columna (-1 = inferir dimensión)
array.min(), array.max()             # Valores mínimo y máximo
```

### Matplotlib:
```python
plt.figure(figsize=(width, height))  # Crear figura con tamaño específico
plt.scatter(x, y, s=size, alpha=transparency, color='color', zorder=order)
plt.plot(x, y, linewidth=width, color='color', label='label')
plt.axhline(y=value, color='color', linewidth=width)  # Línea horizontal
plt.xlabel('label', fontsize=size)
plt.ylabel('label', fontsize=size)
plt.title('title', fontsize=size, fontweight='bold')
plt.legend(fontsize=size)
plt.grid(True, alpha=transparency)
plt.xlim([min, max])
plt.ylim([min, max])
plt.tight_layout()  # Ajustar espaciado automáticamente
plt.show()
plt.clf()  # Limpiar figura
```

---

## 9. TÉCNICAS DE MUESTREO

### Random sampling:
```python
from random import sample

# Obtener índices aleatorios sin reemplazo
idx = list(np.linspace(1, L, L, dtype=int))
idx = sample(idx, p)  # Seleccionar p elementos de idx

# Aplicar a arrays
selected_values = array[idx]
```

---

## 10. RESUMEN DE FLUJO DE TRABAJO

### Para Regresión:
1. Generar/cargar datos
2. Entrenar modelo
3. Hacer predicciones
4. Calcular MSE
5. Calcular correlación
6. Visualizar predicciones vs valores reales

### Para Clasificación:
1. Generar/cargar datos y etiquetas
2. Entrenar modelo y obtener scores
3. Calcular accuracy y MCC
4. Generar curva ROC y calcular AUC
5. Generar curva Precision-Recall
6. Seleccionar threshold óptimo según el problema

### Para evaluar Bias-Variance:
1. Entrenar múltiples modelos con diferentes muestras
2. Comparar predicciones
3. Modelos simples (ej. media) → Alto Bias, Baja Varianza
4. Modelos complejos (ej. polinomio grado alto) → Bajo Bias, Alta Varianza
5. Buscar el grado óptimo que balancee ambos

---

## 11. TIPS Y BUENAS PRÁCTICAS

1. **Siempre establece seeds para reproducibilidad:**
   ```python
   np.random.seed(123)
   random.seed(123)
   ```

2. **Usa múltiples métricas:** No te bases solo en accuracy, especialmente con datos desbalanceados.

3. **Visualiza siempre:** Las gráficas revelan patrones que los números no muestran.

4. **Valida con diferentes muestras:** Como se muestra en el ejemplo de bias-variance, entrena múltiples veces para ver la estabilidad.

5. **Ordena los datos para visualización:** Al graficar curvas, ordena por x para evitar líneas zigzag.

6. **Usa zorder en plots:** Controla qué elementos aparecen encima (valores más altos = más arriba).

7. **Formato de strings:** Usa `.format()` o f-strings para insertar valores en títulos y etiquetas.
   ```python
   'MSE={:.2f}, cor={:.2f}'.format(MSE, cor[0,1])
   ```
