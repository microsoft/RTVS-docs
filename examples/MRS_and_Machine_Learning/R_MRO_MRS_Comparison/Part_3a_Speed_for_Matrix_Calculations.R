## Demonstrates the speed differences in matrix calculations
## across R, Microsoft R Open (MRO), and Microsoft R Server (MRS).

# To learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# Run the following code on R, MRO, and MRS and 
# notice the speed improvement with MRO and MRS over R.

# The code in this section can be found at the following address:
# https://mran.revolutionanalytics.com/documents/rro/multithread/#mt-bench

# Check whether RevoScaleR is available.
suppressWarnings(RRE <- require("RevoScaleR"))
if (!RRE) {
    cat(
    "RevoScaleR package does not seem to exist. \n",
    "This means that the functions starting with 'rx' will not run. \n",
    "If you have Microsoft R Server installed, please switch the R engine.\n",
    "For example, in R Tools for Visual Studio: \n",
    "R Tools -> Options -> R Engine. \n",
    "If Microsoft R Server is not installed, you can download it from: \n",
    "https://www.microsoft.com/en-us/server-cloud/products/r-server/")
    } else {
    # Print the default number of threads if MKL library is installed.
    print(paste("The number of threads is:", getMKLthreads()))
    }

cat("This is a big calculation and may take a few minutes to run.")

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

cat("Save the time and run the code on R, MRO and MRS to compare speed.")