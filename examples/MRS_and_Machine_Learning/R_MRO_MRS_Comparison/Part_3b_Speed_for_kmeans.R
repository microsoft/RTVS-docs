# ----------------------------------------------------------------------------
# purpose:  to demonstrate the speed similarities for kmeans across 
#           R, Microsoft R Open (MRO), and Microsoft R Server (MRS)
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# to learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# ----------------------------------------------------------------------------
# load libraries
# ----------------------------------------------------------------------------
library("MASS") # to use the mvrnorm function

# ----------------------------------------------------------------------------
# run the following analysis that does not involve matrix manipulation 
# to observe that the speed is similar on R, MRO and MRS 
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
