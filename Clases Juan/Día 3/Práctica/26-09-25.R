# Screen Scratch Detection ####

##Clean the workspace#####
rm(list = ls())
graphics.off()

##Input data ######
mu0 <- 0
mu1 <- 0.7
sigma <- 1
n <- 9

delta <- (mu1-mu0)*sqrt(n)/sigma

##alpha######
alpha <- 0.05
z_alpha <- qnorm(1-alpha)

##beta######
beta <- pnorm(z_alpha-delta)
power <- 1-beta

##PPV########
penetrance = 0.01
PPV = (1-beta)*penetrance/((1-beta)*penetrance+alpha*(1-penetrance))

#plot curve of PPV based on different penetrances######
penetrance_values <- seq(from = 0.01, to = 0.5, length.out = 6)
PPV_values = (1-beta)*penetrance_values/((1-beta)*penetrance_values+alpha*(1-penetrance_values))
df <- data.frame(penetrance_values, PPV_values)
ggplot(df, aes(penetrance_values, PPV_values)) + geom_point()

# do the same for evolution of Power based on sample size########
sampleSize_values <- seq(from = 10, to = 100, length.out = 10)
z_alpha <- qnorm(1- alpha)
delta <- (mu1 - mu0) * sqrt(sampleSize_values) / sigma
beta <- pnorm(z_alpha - delta)
power <- 1-beta
df <- data.frame(sampleSize_values, power)
ggplot(df, aes(sampleSize_values, power)) + geom_point()



# EXERCISE 1 - POWER AND SAMPLE SIZE####

## 1A####

# Clean the workspace
rm(list = ls())
graphics.off()
# Input data
u1 <- 3 ; u0 <- 0; sigma <- 10; alpha <- 0.05; beta <- 0.2
# Effect size
d <- abs(u1-u0)/sigma
# Power
power <- 1-beta
# Calculate N using the formula
zalpha <- abs(qnorm(alpha))
zbeta <- abs(qnorm(beta))
N <- 4*((zalpha + zbeta)^2)/d^2


## 1B####

#Calculate N using pwr package
# Load package
library(pwr)
# Apply function for t.test
P <- pwr.t.test(d=d,sig.level=alpha,power=power,type="two.sample",alternative="greater")
Npwr <- 2*P$n
Npwr


## 1C####

# Input data
u1 <- 3 ; u0 <- 0; alpha <- 0.05; beta <- 0.2
sigma <- seq(from = 1, to = 40, length.out = 40)
# Effect size
d <- abs(u1-u0)/sigma
# Power
power <- 1-beta
# Calculate N using the formula
zalpha <- abs(qnorm(alpha))
zbeta <- abs(qnorm(beta))
N <- 4*((zalpha + zbeta)^2)/d^2
#dataframe
df <- data.frame(sigma, N)
ggplot(df, aes(sigma,N)) + geom_point()



# EXERCISE 2 - ANOVA AND SAMPLE SIZE####

## 2A####

# Clean the workspace
rm(list = ls()); graphics.off(); set.seed(500)
# Input Data
n <- 10; u1 <-0.8; u2 <-1; u3 <-1.1; sigma<-1; l <- 3
#after power calculation (Power = 0.5)
#n <- 108; u1 <-0.8; u2 <-1; u3 <-1.1; sigma<-1; l <- 3
# Generate factors
f <- c("T1", "T2", "T3")
tm <- gl(l, 1, n*l, factor (f) )
# Generate output values
t1 <- rnorm(n, u1,sigma)
t2 <- rnorm(n, u2,sigma)
t3 <- rnorm(n, u3,sigma)
y <- matrix (c(t1,t2, t3), nrow=n, ncol=l)
y <- c(t(y))
# Anova
av <- aov(y ~ tm, projections=TRUE)
summary(av)


## 2B####

# Calculating N with pwr package
#(For effect size, we need grand average)
u1 <- 0.8; u2 <- 1; u3 <- 1.1; sigma <- 1; l <- 3
#effect size (cohen's)
grand_mean <- mean(c(u1, u2, u3))
sigma_m2 <- mean((c(u1, u2, u3)-grand_mean)^2)
sigma_m <- sqrt(sigma_m2)
effect <- sigma_m / sigma
pwr <- pwr.anova.test(k=3, f=effect, sig.level=0.05, power=0.5)

# Finalmente, observamos que n = 107.2196
# por lo tanto, aplicamos ese valor a los datos que teníamos antes y veremos que
# un 80% de las veces, da resultados significativos

# Realizamos de nuevo el test de ANOVA para ver los resultados con el tamaño de n correcto

n <- 108; u1 <-0.8; u2 <-1; u3 <-1.1; sigma<-1; l <- 3
f <- c("T1", "T2", "T3")
tm <- gl(l, 1, n*l, factor (f) )
# Generate output values
t1 <- rnorm(n, u1,sigma)
t2 <- rnorm(n, u2,sigma)
t3 <- rnorm(n, u3,sigma)
y <- matrix (c(t1,t2, t3), nrow=n, ncol=l)
y <- c(t(y))
# Anova
av <- aov(y ~ tm, projections=TRUE)
summary(av)


# EXERCISE 4####

# Clean the workspace
rm(list = ls()); graphics.off(); set.seed(500)
# Input Data
n <- 50; u1 <-1; u2 <-2; u3 <-3; sigma<-1; k <- 3; ub <- 10
# Generate factors
f <- c("T1", "T2", "T3")
tm <- gl(k,1, n*k, factor (f))
blocks <- gl(2, 3*n/2, labels=c("Block1", "Block2"))
# Generate output values
b <- c(rep(0,n/2),rep(1,n/2))
t1 <- rnorm(n, u1,sigma) + b*rnorm(n, ub, sigma)
t2 <- rnorm(n, u2,sigma) + b*rnorm(n, ub, sigma)
t3 <- rnorm(n, u3,sigma) + b*rnorm(n, ub, sigma)
y <- matrix (c(t1,t2, t3), nrow=n, ncol=k)
y <- c(t(y))
# Integrate data into data frame
data1 <- data.frame(tm, blocks,y)
# Anova with blocks
av <- aov(y ~ tm + blocks, projections=TRUE, data=data1)
summary(av)
# Anova without blocks
av <- aov(y ~ tm, projections=TRUE, data=data1)
summary(av)


# EXERCISE 5 #####

## 5A ####

# Clean the workspace
rm(list = ls()); graphics.off(); set.seed(500)
# Load libray FrF2
library(FrF2)
# Generate response and design matrix
y <- c(59,74,50,69,50,81,46,79,
       61,70,58,67,54,85,44,81)
design1 <- FrF2(nruns=8, nfactors=3, replications=2, randomize=FALSE)
design1 <- add.response(design1,y)
# Conduct linear model
M1 <- lm(design1, degree=3)
summary(M1)


## 5B #####

# Clean the workspace
rm(list = ls()); graphics.off(); set.seed(500)
# Load libray FrF2
library(FrF2)
# Generate response and design matrix
y <- c(69, 52, 60, 83, 71, 50, 59, 88)
design2 <- FrF2(nruns= 8,nfactor=7, randomize=FALSE)
design2 <- add.response(design2,y)
# Conduct linear model
M2 <- lm(design2, degree=1)
summary(M2)