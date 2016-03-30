## Demonstrates the speed differences in matrix calculations
## across R, Microsoft R Open (MRO), and Microsoft R Server (MRS).

# To learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# Load libraries.
library("MASS") # to use the mvrnorm function

# Run the following analysis that does not involve matrix manipulation 
# to observe that the speed is similar on R, MRO and MRS.
set.seed(0)

# Function to simulate data.
simulCluster <- function(nsamples, mean, dimension, group)
{
  Sigma <- diag(1, dimension, dimension)
  x <- mvrnorm(n = nsamples, rep(mean, dimension), Sigma)
  z <- as.data.frame(x)
  z$group = group
  z
}

# Simulate data. 
nsamples <- 10 ^ 7
# nsamples <- 1000 # for testing purposes
group_a <- simulCluster(nsamples, -1, 2, "a")
group_b <- simulCluster(nsamples, 1, 2, "b")
group_all <- rbind(group_a, group_b)

nclusters <- 2

mydata = group_all[, 1:2]

cat("-----------------------------------------------------------------\n",
    "It might take a while for this to finish if nsamples is large. \n")

# K-Means Cluster Analysis
system_time_r <- system.time(fit <- kmeans(mydata, nclusters,
                                           iter.max = 1000,
                                           algorithm = "Lloyd"))
system_time_r

cat("-----------------------------------------------------------------\n",
    "Save the time and run the code on R, MRO and MRS to compare speed. \n")