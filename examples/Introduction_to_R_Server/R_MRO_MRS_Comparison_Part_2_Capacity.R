# ----------------------------------------------------------------------------
# purpose:  to demonstrate that MRS's rxKmeans() function works 
#           successfully even when kmeans() does not for large datasets
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# to learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# ----------------------------------------------------------------------------
# check if Microsoft R Server (RRE 8.0) is installed
# ----------------------------------------------------------------------------
if (!('RevoScaleR' %in% rownames(installed.packages()))) {
    message("RevoScaleR package does not seem to exist. \nThis means that", 
            " the functions starting with 'rx' will not run. \n")
    message("If you have Mircrosoft R Server installed, please switch \n", 
            "the R engine. For example, in R Tools for Visual Studio: \n", 
            "R Tools -> Options -> R Engine. \n")
    message("If Microsoft R Server is not installed, \n", 
            "please download it from here: \n", 
            "https://www.microsoft.com/en-us/server-cloud/products/r-server/")
}

# ----------------------------------------------------------------------------
# install a library if it's not already installed
# ----------------------------------------------------------------------------
if (!('ggplot2' %in% rownames(installed.packages()))) {
    install.packages("ggplot2")
}

# ----------------------------------------------------------------------------
# load libraries
# ----------------------------------------------------------------------------
library("MASS") # to use the mvrnorm function

# ----------------------------------------------------------------------------
# simulate cluster data for analysis, run this on R, MRO, or MRS
# ----------------------------------------------------------------------------
# make sure the results can be replicated
set.seed(0)

# function to simulate data
simulCluster <- function(nsamples, mean, dimension, group) {
    Sigma <- diag(1, dimension, dimension)
    x_a <- mvrnorm(n=nsamples, rep(mean, dimension), Sigma)
    x_a_dataframe = as.data.frame(x_a)
    x_a_dataframe$group = group
    x_a_dataframe
}

# simulate data and append
# modify the value for nsamples to test out the capacity limit for kmeans()
# kmeans() failed when nsamples is 3*10^7 but rxKmeans() 
# worked on a computer with 7 GB RAM
nsamples <- 3*10^7 
group_a <- simulCluster(nsamples, -1, 2, "a")
group_b <- simulCluster(nsamples, 1, 2, "b")
group_all <- rbind(group_a, group_b)

nclusters <- 2

# save data
mydata = group_all[,1:2]
write.csv(group_all, "simData.csv", row.names=FALSE)
dataCSV = "simData.csv"
dataXDF = "simData.xdf"
rxImport(inData = dataCSV, outFile = dataXDF, overwrite = TRUE)

# ----------------------------------------------------------------------------
# cluster analysis with kmeans(), it doesn't work when data is large enough
# ----------------------------------------------------------------------------
system_time_r <- system.time(fit <- kmeans(mydata, nclusters, 
                                           iter.max = 1000, 
                                           algorithm = "Lloyd")) 

# ----------------------------------------------------------------------------
# cluster analysis with rxKmeans(), it works even if kmeans() does not
# ----------------------------------------------------------------------------
system_time_rre <- system.time(clust <- rxKmeans(~ V1 + V2, data= dataXDF,
                                                 numClusters = nclusters, 
                                                 algorithm = "lloyd", 
                                                 outFile = dataXDF, 
                                                 outColName = "cluster", 
                                                 overwrite = TRUE))
