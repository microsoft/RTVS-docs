# ----------------------------------------------------------------------------
# purpose:  to demonstrate that MRS's rxKmeans() function works 
#           successfully even when kmeans() does not for large datasets
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# to learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# ----------------------------------------------------------------------------
# check if Microsoft R Server is installed and load libraries
# ----------------------------------------------------------------------------
# to check if RevoScaleR is available
RRE <- require("RevoScaleR") 
if (RRE)
{
  message(
    "RevoScaleR package does not seem to exist. \n",
    "This means that the functions starting with 'rx' will not run. \n",
    "If you have Microsoft R Server installed, please switch the R engine.\n",
    "For example, in R Tools for Visual Studio: \n",
    "R Tools -> Options -> R Engine. \n",
    "If Microsoft R Server is not installed, you can download it from: \n",
    "https://www.microsoft.com/en-us/server-cloud/products/r-server/")
}

# install a package if it's not already installed
if (!require("ggplot2", quietly = TRUE)) install.packages("ggplot2")

# load packages
library("MASS") # to use the mvrnorm function
library("ggplot2") # used for plotting

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
# modify the value for nsamples to test out the capacity limit for kmeans()
# on a computer with 7 GB RAM, when nsamples is 3*10^7 kmeans() failed 
# but rxKmeans() worked 
message("If the sample size is large, it will take some time to finish. \n",
        "You can use a smaller value for nsamples, say 1000, \n", 
        "to test the program.")
nsamples <- 3 * 10 ^ 7
group_a <- simulCluster(nsamples, -1, 2, "a")
group_b <- simulCluster(nsamples, 1, 2, "b")
group_all <- rbind(group_a, group_b)

nclusters <- 2

# plot sample data
plot_data <- group_all[sample(2 * nsamples, min(1000, 2 * nsamples)),] 
ggplot(plot_data, aes(x = V1, y = V2)) +
  geom_point(aes(colour = group)) +
  geom_point(data = data.frame(V1 = c(-1, 1), V2 = c(-1, 1)), size = 5) +
  xlim(-5, 5) + ylim(-5, 5) +
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = 0) +
  ggtitle("Simulated Data in Two Overlapping Groups")

# save data
mydata = group_all[, 1:2]
dataCSV = tempfile(fileext = ".csv")
dataXDF = tempfile(fileext = ".xdf")
write.csv(group_all, dataCSV, row.names = FALSE)

# ----------------------------------------------------------------------------
# cluster analysis with kmeans(), it doesn't work when data is large enough
# ----------------------------------------------------------------------------
# this can be run on R, MRO, or MRS
system_time_R <- 
  system.time(
    {
      fit <- kmeans(mydata, nclusters,
                    iter.max = 1000,
                    algorithm = "Lloyd")
    })

# ----------------------------------------------------------------------------
# cluster analysis with rxKmeans() on MRS, it works even if kmeans() does not
# ----------------------------------------------------------------------------
# cluster analysis with rxKmeans() if RevoScaleR is installed
if (RRE){
  rxImport(inData = dataCSV, outFile = dataXDF, overwrite = TRUE)
  
  system.time(
    {
      clust <- rxKmeans( ~ V1 + V2, data = dataXDF,
                         numClusters = nclusters,
                         algorithm = "lloyd",
                         outFile = dataXDF,
                         outColName = "cluster",
                         overwrite = TRUE)
    })
} else {
  print("rxKmeans was not run becauase the RevoScaleR package is not available")
}