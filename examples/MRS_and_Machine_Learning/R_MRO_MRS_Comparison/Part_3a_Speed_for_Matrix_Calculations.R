## Demonstrates the speed differences in matrix calculations
## across R, Microsoft R Open (MRO), and Microsoft R Server (MRS).

# To learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# Run the following code on R, MRO, and MRS and 
# notice the speed improvement with MRO and MRS over R.

# The code in this section can be found at the following address:
# https://mran.revolutionanalytics.com/documents/rro/multithread/#mt-bench

cat("-----------------------------------------------------------------\n",
    "This is a big calculation and may take a few minutes to run. \n")

# print the default number of threads if MKL library is installed
if (require("RevoUtilsMath")) {
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

cat("-----------------------------------------------------------------\n",
    "Save the time and run the code on R, MRO and MRS to compare speed.")