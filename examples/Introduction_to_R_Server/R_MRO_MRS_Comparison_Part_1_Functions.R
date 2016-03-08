# ----------------------------------------------------------------------------
# purpose:  to demonstrate the commonalities and differences among functions
#           in R, Microsoft R Open (MRO), and Microsoft R Server (MRS)
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# to learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# ----------------------------------------------------------------------------
# check if Microsoft R Server (RRE 8.0) is installed
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
# fit a model with glm(), this can be run on R, MRO, or MRS
# ----------------------------------------------------------------------------
# check the data
head(mtcars)
# predict V engine vs straight engine with weight and displacement
logistic1 <- glm(vs ~ wt + disp, data = mtcars, family = binomial)
summary(logistic1)

# ----------------------------------------------------------------------------
# fit the same model with rxGlm(), this can be run on MRS only
# ----------------------------------------------------------------------------
# check the data
head(mtcars)
# predict V engine vs straight engine with weight and displacement
logistic2 <- rxGlm(vs ~ wt + disp, data = mtcars, family = binomial)
summary(logistic2)

# ----------------------------------------------------------------------------
# simulate cluster data for analysis, on R, MRO, or MRS
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

# simulate data with 2 clusters
nsamples <- 1000
group_a <- simulCluster(nsamples, -1, 2, "a")
group_b <- simulCluster(nsamples, 1, 2, "b")
group_all <- rbind(group_a, group_b)

nclusters <- 2

# plot data 
layer1 <- ggplot() + geom_point(data=group_all,aes(x=V1,y=V2,colour=group)) +
    xlim(-5,5) + ylim(-5,5)
DF2 <- as.data.frame(matrix(c(-1,-1, 1,1), ncol = 2, byrow = TRUE))
names(DF2) <- c("X","Y")
layer2 <- geom_point(data=DF2, aes(x=X,y=Y))
layer1 + layer2 + geom_hline(yintercept = 0) + geom_vline(xintercept = 0)

# assign data 
mydata = group_all[,1:2]

# ----------------------------------------------------------------------------
# cluster analysis with kmeans(), it works on R, MRO, or MRS
# ----------------------------------------------------------------------------
fit.kmeans <- kmeans(mydata, nclusters, iter.max = 1000, algorithm = "Lloyd")

# ----------------------------------------------------------------------------
# cluster analysis with rxKmeans(), it works on MRS only
# ----------------------------------------------------------------------------
fit.rxKmeans <- rxKmeans(~ V1 + V2, data= mydata, 
                         numClusters = nclusters, algorithm = "lloyd")

# ----------------------------------------------------------------------------
# compare the cluster assignments between kmeans() and rxKmeans(): the same
# the code below should be run on MRS due to the use of "rx" commands
# ----------------------------------------------------------------------------
# save a dataset in XDF format
dataXDF = "testData.xdf"
rxImport(inData = mydata, outFile = dataXDF, overwrite = TRUE)
# rxKmeans
clust <- rxKmeans(~ V1 + V2, data= dataXDF, numClusters = nclusters,
                  algorithm = "lloyd", outFile = dataXDF, 
                  outColName = "cluster", overwrite = TRUE)

# append cluster assignment from kmeans
mydata_clusters <- data.frame(group_all, kmeans.cluster = fit.kmeans$cluster)
mydata_clusters$kmeans.cluster <- factor(mydata_clusters$kmeans.cluster)

# append cluster assignment from rxKmeans
mydata_xdf <- rxXdfToDataFrame(file=dataXDF)
mydata_clusters$rxKmeans.cluster <- factor(mydata_xdf$cluster)
head(mydata_clusters)

# compare the cluster assignments between kmeans and rxKmeans
# first switch cluster assignment for rxKmeans
mydata_clusters$rxKmeans.cluster.c <- 3-as.numeric(
    mydata_clusters$rxKmeans.cluster) 
# then summarize
table(mydata_clusters$kmeans.cluster, mydata_clusters$rxKmeans.cluster)
table(mydata_clusters$kmeans.cluster, mydata_clusters$rxKmeans.cluster.c)

# get cluster means 
clustermeans.kmeans <- aggregate(mydata,
                                 by=list(mydata_clusters$kmeans.cluster),
                                 FUN=mean)
clustermeans.rxKmeans <- aggregate(mydata,
                                   by=list(mydata_clusters$rxKmeans.cluster),
                                   FUN=mean)

# plot clusters from kmeans
layer1 <- ggplot() + 
    geom_point(data=mydata_clusters,aes(x=V1,y=V2,colour=kmeans.cluster)) + 
    xlim(-5,5) + ylim(-5,5)
DF2 <- as.data.frame(clustermeans.kmeans[,2:3])
names(DF2) <- c("X","Y")
layer2 <- geom_point(data=DF2, aes(x=X,y=Y))
layer1 + layer2 + geom_hline(yintercept = 0) + geom_vline(xintercept = 0)

# plot clusters from rxKmeans
layer1 <- ggplot() + 
    geom_point(data=mydata_clusters, 
               aes(x=V1,y=V2,colour=rxKmeans.cluster)) + 
    xlim(-5,5) + ylim(-5,5)
DF2 <- as.data.frame(clustermeans.rxKmeans[,2:3])
names(DF2) <- c("X","Y")
layer2 <- geom_point(data=DF2, aes(x=X,y=Y))
layer1 + layer2 + geom_hline(yintercept = 0) + geom_vline(xintercept = 0)
