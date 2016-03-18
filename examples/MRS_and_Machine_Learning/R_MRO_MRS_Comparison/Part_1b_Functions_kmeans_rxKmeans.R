# ----------------------------------------------------------------------------
# purpose:  to demonstrate the commonalities and differences among functions
#           in R, Microsoft R Open (MRO), and Microsoft R Server (MRS)
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# to learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# ----------------------------------------------------------------------------
# check if Microsoft R Server is installed and load libraries
# ----------------------------------------------------------------------------
# to check if RevoScaleR is available
RRE <- require("RevoScaleR") 
if (!RRE)
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
# simulate data, it works on R, MRO, or MRS
# ----------------------------------------------------------------------------
# make sure the results can be replicated
set.seed(121)

# function to simulate data 
simulCluster <- function(nsamples, mean, dimension, group)
{
  Sigma <- diag(1, dimension, dimension)
  x <- mvrnorm(n = nsamples, rep(mean, dimension), Sigma)
  z <- as.data.frame(x)
  z$group = group
  z
}

# simulate data with 2 clusters
nsamples <- 1000
group_all <- rbind(
  simulCluster(nsamples, -1, 2, "a"),
  simulCluster(nsamples, 1, 2, "b"))

nclusters <- 2

# plot data 
ggplot(group_all, aes(x = V1, y = V2)) +
  geom_point(aes(colour = group)) +
  geom_point(data = data.frame(V1 = c(-1, 1), V2 = c(-1, 1)), size = 5) +
  xlim(-5, 5) + ylim(-5, 5) +
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = 0) +
  ggtitle("Simulated Data in Two Overlapping Groups")

# assign data 
mydata <- group_all[, 1:2]

# ----------------------------------------------------------------------------
# kmeans 
# ----------------------------------------------------------------------------
# cluster analysis with kmeans(), it works on R, MRO, or MRS
fit.kmeans <- kmeans(mydata, nclusters, iter.max = 1000, algorithm = "Lloyd")

mydata_clusters <- cbind(
  group_all,
  kmeans.cluster = factor(fit.kmeans$cluster))

# get cluster means 
clustermeans.kmeans <- fit.kmeans$centers

# plot clusters from kmeans
ggplot(mydata_clusters, aes(x = V1, y = V2)) +
  geom_point(aes(colour = kmeans.cluster)) +
  geom_point(data = as.data.frame(clustermeans.kmeans), size = 5) +
  xlim(-5, 5) + ylim(-5, 5) +
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = 0) +
  ggtitle("Clusters Found by kmeans()")

# ----------------------------------------------------------------------------
# cluster analysis with rxKmeans(), it works on MRS only
# ----------------------------------------------------------------------------

# cluster analysis with rxKmeans() if RevoScaleR is installed
if (RRE){
  # save a dataset in XDF format
  dataXDF = tempfile(fileext = ".xdf")
  rxImport(inData = mydata, outFile = dataXDF, overwrite = TRUE)
  
  # rxKmeans
  clust <- rxKmeans(~ V1 + V2, data = dataXDF, 
                    numClusters = nclusters, algorithm = "lloyd",
                    outFile = dataXDF, outColName = "cluster", 
                    overwrite = TRUE)
  
  rxKmeans.cluster <- rxDataStep(dataXDF, varsToKeep = "cluster")
  
  # append cluster assignment from kmeans and rxKmeans
  mydata_clusters <- cbind(
    group_all,
    kmeans.cluster = factor(fit.kmeans$cluster),
    rxKmeans.cluster = factor(rxKmeans.cluster$cluster))
  
  # compare the cluster assignments between kmeans and rxKmeans
  message("\nComparing cluster assignments between kmeans and rxKmeans:")
  print(with(mydata_clusters, table(kmeans.cluster, rxKmeans.cluster)))
  
  # get cluster means 
  clustermeans.rxKmeans <- fit.kmeans$centers
  
  # plot clusters from rxKmeans
  ggplot(mydata_clusters, aes(x = V1, y = V2)) +
    geom_point(aes(colour = rxKmeans.cluster)) +
    geom_point(data = as.data.frame(clustermeans.kmeans), size = 5) +
    xlim(-5, 5) + ylim(-5, 5) +
    geom_hline(yintercept = 0) +
    geom_vline(xintercept = 0) +
    ggtitle("Clusters Found by rxKmeans()")
  
} else{
  print("rxKmeans was not run becauase the RevoScaleR package is not available")
}

