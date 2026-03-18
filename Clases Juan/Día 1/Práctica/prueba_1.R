library(tidyverse)
library(dplyr)
library(tidyr)
library(purrr)
library(tibble)
library(ggplot2)
library(jsonlite)
library(nycflights13)
# Data
media = 3
varianza = 2
x <- seq(media-4*sqrt(varianza),media+4*sqrt(varianza),0.01)
y <- dnorm(x,mean=media,sd=sqrt(varianza))
plot(x,y,type="l",ylim = c(0,2))
#media es centrado y consistente.
A <- matrix(rnorm(10000*10,mean=media,sd=sqrt(varianza)),nrow=10000)
medias_n10 <- rowMeans(A)
lines(density(medias_n10),col="red")
B <- matrix(rnorm(10000*20,mean=media,sd=sqrt(varianza)),nrow=10000)
medias_n20 <- rowMeans(B)
lines(density(medias_n20),col="blue")
abline(v = media) #se ve que estan centrados

#que pasa con la varianza??
library(matrixStats)
vars_n10 <- rowVars(A)
plot(density(vars_n10),col="red",ylim=c(0,2))
mean(vars_n10)
vars_n20 <- rowVars(B)
lines(density(vars_n20),col="blue")
mean(vars_n20)
D <- matrix(rnorm(10000*100,mean=media,sd=sqrt(varianza)),nrow=10000)
vars_n100 <- rowVars(D)
lines(density(vars_n100),col="green")
abline(v=varianza) #se ve que estan centrados
mean(vars_n100)

# Aqui es lo que teniamos que hacer en clase

#son robustos
random <- rnorm(100,mean=media,sd=sqrt(varianza))
mean(random)
var(random)
#que pasa si metemos un valor atipico (outlier)
random[1] <- 1000
mean(random)
median(random)
sd(random)
mad(random)
var(random)
sqrt(varianza)

medianas_n20 <- rowMedians(B)
plot(density(medias_n20),col="blue")
lines(density(medianas_n20),col="red")


#intervalo de confianza