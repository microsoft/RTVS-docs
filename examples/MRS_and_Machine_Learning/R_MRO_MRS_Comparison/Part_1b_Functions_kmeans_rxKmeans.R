## Demonstrates the commonalities and differences beteween functions
## in R, Microsoft R Open (MRO), and Microsoft R Server (MRS).
## Part 1b looks at kMeans clustering.

# To learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# Check whether Microsoft R Server is installed and load libraries.
# Check whether RevoScaleR is available.
suppressWarnings(RRE <- require("RevoScaleR"))
if (!RRE)
{
  cat("-----------------------------------------------------------------\n",
    "RevoScaleR package does not seem to exist. \n",
    "This means that the functions starting with 'rx' will not run. \n",
    "If you have Microsoft R Server installed, please switch the R engine.\n",
    "For example, in R Tools for Visual Studio: \n",
    "R Tools -> Options -> R Engine. \n",
    "If Microsoft R Server is not installed, you can download it from: \n",
    "https://www.microsoft.com/en-us/server-cloud/products/r-server/ \n")
}

# Install ggplot2 if it's not already installed.
if (!require("ggplot2", quietly = TRUE)) install.packages("ggplot2")

# Load packages.
library("MASS") # to use the mvrnorm function
library("ggplot2") # used for plotting

# Simulate data. This works on R, MRO, or MRS.
# Make sure the results can be replicated by setting the random seed.
set.seed(121)

# Function to simulate data .
simulCluster <- function(nsamples, mean, dimension, group)
{
  Sigma <- diag(1, dimension, dimension)
  x <- mvrnorm(n = nsamples, rep(mean, dimension), Sigma)
  z <- as.data.frame(x)
  z$group = group
  z
}

# Simulate data with 2 clusters.
nsamples <- 1000
group_all <- rbind(
  simulCluster(nsamples, -1, 2, "a"),
  simulCluster(nsamples, 1, 2, "b"))

nclusters <- 2

# Plot data. 
ggplot(group_all, aes(x = V1, y = V2)) +
  geom_point(aes(colour = group)) +
  geom_point(data = data.frame(V1 = c(-1, 1), V2 = c(-1, 1)), size = 5) +
  xlim(-5, 5) + ylim(-5, 5) +
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = 0) +
  ggtitle("Simulated Data in Two Overlapping Groups")

# Assign data.
mydata <- group_all[, 1:2]


### kmeans 

# Perform cluster analysis with kmeans(). This works on R, MRO, or MRS.
fit_kmeans <- kmeans(mydata, nclusters, iter.max = 1000, algorithm = "Lloyd")

mydata_clusters <- cbind(
  group_all,
  kmeans_cluster = factor(fit_kmeans$cluster))

# Get cluster centroids. 
cluster_centroid_kmeans <- fit_kmeans$centers

# Plot clusters from kmeans.
ggplot(mydata_clusters, aes(x = V1, y = V2)) +
  geom_point(aes(colour = kmeans_cluster)) +
  geom_point(data = as.data.frame(cluster_centroid_kmeans), size = 5) +
  xlim(-5, 5) + ylim(-5, 5) +
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = 0) +
  ggtitle("Clusters Found by kmeans()") + 
  theme(legend.title=element_blank())


### Perform cluster analysis with rxKmeans(). This works on MRS only.

# Perform cluster analysis with rxKmeans() if RevoScaleR is installed.
if (RRE){
  # Save a dataset in XDF format.
  dataXDF = tempfile(fileext = ".xdf")
  rxImport(inData = mydata, outFile = dataXDF, overwrite = TRUE)
  
  # rxKmeans
  fit_rxKmeans <- rxKmeans(~ V1 + V2, data = dataXDF, 
                    numClusters = nclusters, algorithm = "lloyd",
                    outFile = dataXDF, outColName = "cluster", 
                    overwrite = TRUE)
  
  cluster_rxKmeans <- rxDataStep(dataXDF, varsToKeep = "cluster")
  
  # Append cluster assignment from kmeans and rxKmeans.
  mydata_clusters <- cbind(
    group_all,
    cluster_kmeans = factor(fit_kmeans$cluster),
    cluster_rxKmeans = factor(cluster_rxKmeans$cluster))
  
  # Compare the cluster assignments between kmeans and rxKmeans.
  cat("\nComparing cluster assignments between kmeans and rxKmeans:")
  print(with(mydata_clusters, table(cluster_kmeans, cluster_rxKmeans)))
  
  # Get cluster means.
  cluster_centroid_rxKmeans <- fit_rxKmeans$centers
  
  # Plot clusters from rxKmeans.
  ggplot(mydata_clusters, aes(x = V1, y = V2)) +
    geom_point(aes(colour = cluster_rxKmeans)) +
    geom_point(data = as.data.frame(cluster_centroid_rxKmeans), size = 5) +
    xlim(-5, 5) + ylim(-5, 5) +
    geom_hline(yintercept = 0) +
    geom_vline(xintercept = 0) +
    ggtitle("Clusters Found by rxKmeans()") + 
    theme(legend.title=element_blank())
  
} else {
    cat("-----------------------------------------------------------------\n",
    "rxKmeans was not run because the RevoScaleR package is not available.\n")
}

