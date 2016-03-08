# ----------------------------------------------------------------------------
# purpose:  to demonstrate that MRS's rxKmeans() function works 
#           successfully even when kmeans() does not for large datasets
# audience: you are expected to have some prior experience with R
#
# NOTE: On a computer with less than 7GB of RAM available, this 
# script may not be able to run to completion.
# ----------------------------------------------------------------------------

# to learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# ----------------------------------------------------------------------------
# check if Microsoft R Server is installed
# ----------------------------------------------------------------------------
if (require("RevoScaleR")) {
    library("RevoScaleR") # Load RevoScaleR package from Microsoft R Server.
    message("RevoScaleR package is succesfully loaded.")
} else {
    message("Can't find RevoScaleR package...")
    message("If you have Microsoft R Server installed,")
    message("please switch the R engine")
    message("in R Tools for Visual Studio: R Tools -> Options -> R Engine.")
    message("If Microsoft R Server is not installed,")
    message("please download it from here:")
    message("https://www.microsoft.com/en-us/server-cloud/products/r-server/.")
}

# ----------------------------------------------------------------------------
# install a library if it's not already installed
# ----------------------------------------------------------------------------
(if (!require("ggplot2")) install.packages("ggplot2"))
library("ggplot2")
(if (!require("MASS")) install.packages("MASS"))
library("MASS") # used for plotting

# ----------------------------------------------------------------------------
# simulate cluster data for analysis, run this on R, MRO, or MRS
# ----------------------------------------------------------------------------
# make sure the results can be replicated
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

# simulate data and append
# Modify the value for nsamples to test out the capacity limit for kmeans().
# kmeans() failed when nsamples is 3*10^7 but rxKmeans() 
# worked on a computer with 7 GB RAM
nsamples <- 3 * 10 ^ 7
group_a <- simulCluster(nsamples, -1, 2, "a")
group_b <- simulCluster(nsamples, 1, 2, "b")
group_all <- rbind(group_a, group_b)

nclusters <- 2

# save data
mydata = group_all[, 1:2]
write.csv(group_all, "simData.csv", row.names = FALSE)
dataCSV = "simData.csv"
dataXDF = "simData.xdf"
rxImport(inData = dataCSV, outFile = dataXDF, overwrite = TRUE)

# ----------------------------------------------------------------------------
# cluster analysis with kmeans(), it doesn't work when data is large enough
# ----------------------------------------------------------------------------
system.time(
{
  fit <- kmeans(mydata, nclusters,
                iter.max = 1000,
                algorithm = "Lloyd")
})

# ----------------------------------------------------------------------------
# cluster analysis with rxKmeans(), it works even if kmeans() does not
# ----------------------------------------------------------------------------
system.time(
{
  clust <- rxKmeans( ~ V1 + V2, data = dataXDF,
                    numClusters = nclusters,
                    algorithm = "lloyd",
                    outFile = dataXDF,
                    outColName = "cluster",
                    overwrite = TRUE)
})
