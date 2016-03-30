## Demonstrates the speed differences in matrix calculations
## across R, Microsoft R Open (MRO), and Microsoft R Server (MRS).
## This script compares the speed of kmeans() with that of rxKmeans()  
## on Microsoft R Server (MRS).

# To learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# Check whether Microsoft R Server is installed and load libraries.
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

# Install a package if it's not already installed.
if (!require("MASS", quietly = TRUE))
    install.packages("MASS")
if (!require("ggplot2", quietly = TRUE))
    install.packages("ggplot2")

# Load libraries.
library("MASS") # to use the mvrnorm function
library("ggplot2") # used for plotting


### Compare the speed of kmeans with that of rxKmeans on MRS
### for different data sizes

# To save timing results.
myresult <- data.frame(nsamples = integer(), time_r = double(),
                       time_rre = double())

# List of sample sizes.
nsamples_list <- c(5 * 10 ^ 2, 10 ^ 3, 5 * 10 ^ 3,
                   10 ^ 4, 5 * 10 ^ 4, 10 ^ 5,
                   5 * 10 ^ 5, 10 ^ 6, 5 * 10 ^ 6, 10 ^ 7)

# Function to simulate data.
simulCluster <- function(nsamples, mean, dimension, group)
{
  Sigma <- diag(1, dimension, dimension)
  x <- mvrnorm(n = nsamples, rep(mean, dimension), Sigma)
  z <- as.data.frame(x)
  z$group = group
  z
}

cat("-----------------------------------------------------------------\n",
    "It might take a while for this to finish if any of the elements in", 
    "nsamples_list is large.")

for (nsamples in nsamples_list)
{
  # Simulate data and append.
  group_a <- simulCluster(nsamples, -1, 2, "a")
  group_b <- simulCluster(nsamples, 1, 2, "b")
  group_all <- rbind(group_a, group_b)
  mydata = group_all[, 1:2]
  
  nclusters <- 2
  
  # kmeans with R
  system_time_r <- system.time(fit <- kmeans(mydata, nclusters,
                                             iter.max = 1000,
                                             algorithm = "Lloyd"))
  
  # kmeans with MRS
  
  if (RRE){
    system_time_rre <- system.time(clust <- rxKmeans( ~ V1 + V2, 
                                                      data = mydata,
                                                      numClusters = nclusters,
                                                      algorithm = "lloyd"))
  }
  else system_time_rre <- c(NA,NA,NA)
  
  # combine
  newrow <- data.frame(nsamples = nsamples,
                       time_r = as.numeric(system_time_r[3]),
                       time_rre = as.numeric(system_time_rre[3]))
  myresult <- rbind(myresult, newrow)
  
}

myresult$nsamples <- 2 * myresult$nsamples
mydata <- myresult
mydata$nsamples_log <- log10(mydata$nsamples)
mydata

# Generate plot.
if (RRE){
  ggplot(data = mydata, aes(x = nsamples_log)) +
    geom_point(aes(y = time_r, colour = "kmeans")) +
    geom_line(aes(y = time_r, colour = "kmeans")) +
    geom_point(aes(y = time_rre, colour = "rxKmeans")) +
    geom_line(aes(y = time_rre, colour = "rxKmeans")) +
    scale_x_continuous(breaks = seq(2, 8, by = 1)) +
    scale_colour_manual("Function", 
                        values = c(kmeans = "red", rxKmeans = "blue")) +
    xlab("log10(number of samples)") +
    ylab("time in seconds") +
    ggtitle(paste("If data fits in memory,", 
                  "kmeans() and rxKmeans() are equally performant"))
} else {
  ggplot(data = mydata, aes(x = nsamples_log)) +
    geom_point(aes(y = time_r, colour = "kmeans")) +
    geom_line(aes(y = time_r, colour = "kmeans")) +
    scale_x_continuous(breaks = seq(2, 8, by = 1)) +
    scale_colour_manual("Function", values = c(kmeans = "red")) +
    xlab("log10(number of samples)") +
    ylab("time in seconds") +
    ggtitle(paste("Time for kmeans \n", 
                  "To add time for rxKmeans, use the R Server engine"))
}