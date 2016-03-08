# ----------------------------------------------------------------------------
# purpose:  to demonstrate the speed differences across 
#           R, Microsoft R Open (MRO), and Microsoft R Server (MRS)
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# to learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# ----------------------------------------------------------------------------
# check if Microsoft R Server (RRE 8.0) is installed
# ----------------------------------------------------------------------------
if (!require("RevoScaleR"))
{
  stop(
    "RevoScaleR package does not seem to exist. \n",
    "This means that the functions starting with 'rx' will not run. \n",
    "If you have Microsoft R Server installed, please switch the R engine.\n",
    "For example, in R Tools for Visual Studio: \n",
    "R Tools -> Options -> R Engine. \n",
    "If Microsoft R Server is not installed, you can download it from: \n",
    "https://www.microsoft.com/en-us/server-cloud/products/r-server/")
}

# install a package if it's not already installed
if (!require("ggplot2", quietly = TRUE))
  install.packages("ggplot2")

# ----------------------------------------------------------------------------
# load libraries
# ----------------------------------------------------------------------------
library("MASS") # to use the mvrnorm function
library("ggplot2") # used for plotting

# ----------------------------------------------------------------------------
# run the following code on R, MRO, and MRS and 
# notice the speed improvement with MRO and MRS over R
# ----------------------------------------------------------------------------
# the code in this section can be found at the following address
# https://mran.revolutionanalytics.com/documents/rro/multithread/#mt-bench

# print the default number of threads if MKL library is installed
if (require("RevoUtilsMath"))
{
  print(paste("The number of threads is:", getMKLthreads()))
}

# Initialization
set.seed(1)
m <- 10000
n <- 5000
A <- matrix(runif(m * n), m, n)

# Matrix multiply
system.time(B <- crossprod(A))

# Cholesky Factorization
system.time(C <- chol(B))

# Singular Value Decomposition
m <- 10000
n <- 2000
A <- matrix(runif(m * n), m, n)
system.time(S <- svd(A, nu = 0, nv = 0))

# Principal Components Analysis
m <- 10000
n <- 2000
A <- matrix(runif(m * n), m, n)
system.time(P <- prcomp(A))

# Linear Discriminant Analysis
library("MASS")
g <- 5
k <- round(m / 2)
A <- data.frame(A, fac = sample(LETTERS[1:g], m, replace = TRUE))
train <- sample(1:m, k)
system.time(L <- lda(fac ~ ., data = A, prior = rep(1, g) / g, subset = train))

# ----------------------------------------------------------------------------
# run an analysis that does not involve matrix to show that 
# the speed is similar on R, MRO and MRS
# ----------------------------------------------------------------------------
set.seed(0)

# function to simulate data
simulCluster <- function(nsamples, mean, dimension, group)
{
  Sigma <- diag(1, dimension, dimension)
  x <- mvrnorm(n = nsamples, rep(mean, dimension), Sigma)
  z <- as.data.frame(x)
  z$group = group
  z
}

# simulate data 
nsamples <- 10 ^ 7 # this was used on different platforms
# nsamples <- 1000 # for testing purpose
group_a <- simulCluster(nsamples, -1, 2, "a")
group_b <- simulCluster(nsamples, 1, 2, "b")
group_all <- rbind(group_a, group_b)

nclusters <- 2

mydata = group_all[, 1:2]
# K-Means Cluster Analysis
system_time_r <- system.time(fit <- kmeans(mydata, nclusters,
                                           iter.max = 1000,
                                           algorithm = "Lloyd"))

# ----------------------------------------------------------------------------
# compare the speed of kmeans() with that of rxKmeans() 
# for different data sizes
# ----------------------------------------------------------------------------
myresult <- data.frame(nsamples = integer(), time_r = double(),
                       time_rre = double())

nsamples_list <- c(5 * 10 ^ 2, 10 ^ 3, 5 * 10 ^ 3, 10 ^ 4, 5 * 10 ^ 4, 10 ^ 5,
                   5 * 10 ^ 5, 10 ^ 6, 5 * 10 ^ 6, 10 ^ 7)

for (nsamples in nsamples_list)
{
  # simulate data and append
  group_a <- simulCluster(nsamples, -1, 2, "a")
  group_b <- simulCluster(nsamples, 1, 2, "b")
  group_all <- rbind(group_a, group_b)
  mydata = group_all[, 1:2]

  nclusters <- 2

  # kmeans with R
  system_time_r <- system.time(fit <- kmeans(mydata, nclusters,
                                               iter.max = 1000,
                                               algorithm = "Lloyd"))

  # kmeans with MRS
  system_time_rre <- system.time(clust <- rxKmeans( ~ V1 + V2, data = mydata,
                                                     numClusters = nclusters,
                                                     algorithm = "lloyd"))

  # combine
  newrow <- data.frame(nsamples = nsamples,
                         time_r = as.numeric(system_time_r[3]),
                         time_rre = as.numeric(system_time_rre[3]))
  myresult <- rbind(myresult, newrow)

}

myresult$nsamples <- 2 * myresult$nsamples
mydata <- myresult
mydata$nsamples_log <- log10(mydata$nsamples)

mydata

ggplot(data = mydata, aes(x = nsamples_log)) +
    geom_point(aes(y = time_r, colour = "kmeans")) +
    geom_line(aes(y = time_r, colour = "kmeans")) +
    geom_point(aes(y = time_rre, colour = "rxKmeans")) +
    geom_line(aes(y = time_rre, colour = "rxKmeans")) +
    scale_x_continuous(breaks = seq(2, 8, by = 1)) +
    scale_colour_manual("Function", values = c(kmeans = "red", rxKmeans = "blue")) +
    xlab("log10(number of samples)") +
    ylab("time in seconds") +
    ggtitle("If data fits in memory, kmeans() and rxKmeans() are equally performant")
