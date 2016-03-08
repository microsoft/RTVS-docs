# ---	
# title: "9 - Clustering"	
# ---	

# The checkpoint function installs all required dependencies (i.e. CRAN packages)
# you need to run the examples.
if (!require(checkpoint, quietly = TRUE))
  install.packages("checkpoint")
library(checkpoint)
checkpoint("2016-01-01")


# In this script we will look at Kmeans and hierarchical clustering using the weather data.	

set.seed(42)
(if (!require("rattle")) install.packages("rattle"))
library(rattle)	
(if (!require("fpc")) install.packages("fpc"))
library("fpc")  	                       # for the plotcluster function	
(if (!require("Hmisc")) install.packages("Hmisc"))
library("Hmisc")                         # for varclus function	


### Weather Data	
data(weather, package = "rattle")
weather <- weather[,-c(1,2)]           # Drop the first two columns	
head(weather)                          # Look at the data	

### KMEANS with plot and statistics	

# Note that the K means algorithm requires numeric variables	

numvars <- lapply(weather,is.numeric)			# Find numeric variables in data set	
numdata <- na.omit(weather[,numvars==TRUE])	
head(numdata)	
km <- kmeans(x=numdata, centers=3) 	

# Generate a scatter plots of the variables colored by clusters	

vars <- 1:5	
plot(numdata[vars], col=km$cluster)	
title(main="weather",	
    sub=paste(format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))	

# Note that in the plot: "left" variable is on the y axis and the "under" variable is on the x axis	

# Next, we determine number of clusters by looking for a "knee" in the curve, i.e. the largest drop in the within sum of squares in the plot below	

numdataS <- scale(numdata)  		# Scale the data: (x - m)/sd	
	
ssPlot <- function(data,maxCluster=15){	
			    SSw  <- (nrow(data)-1)*sum(apply(data,2,var))   # Initialize within sum of squares 	
			    SSw <- vector()	
				  for (i in 2:maxCluster){	
					     SSw[i] <- sum(kmeans(data,centers=i)$withinss)	
				  }	
			    plot(1:maxCluster, SSw, type="b", 	
				             xlab="Number of Clusters",	
                     ylab="Within groups sum of squares") 	
		      }	
ssPlot(numdataS)	

# The plotcluster function in the fpc package. There are parameters to distinguis classes by ten available projection methods, including classical discriminant coordinates, methods to project differences in mean and covariance structure, asymmetric methods (separation of a homogeneous class from a heterogeneous one), local neighborhood-based methods and methods based on robust covariance matrices. One-dimensional data is plotted against the cluster number. 	

kmPlot <- function(data,nclust=3,...)	
		{	
			km <- kmeans(x=data, centers=nclust)     	
			plotcluster(x=data,clvecd=km$cluster,...)            # plot fcn from fpc package	
			title(main=paste(nclust, " clusters"))	
			cluster.stats(dist(data),km$cluster)                 # Compute cluster stats with fcn from fpc package	
			return(km)	
		}	
	
par(mfrow=c(2,2))	
kmod <- kmPlot(numdataS)	
kmod8 <- kmPlot(numdataS,nclust=8)	
kmod2 <- kmPlot(numdataS,nclust=2)	
kmod2b <- kmPlot(numdataS,nclust=2,clnum=1,method="bc")	


### Hierarchical Clustering	

# The following function to produce a hierarchical correlation plot. It follows code on page 135 of Data Mining with Rattle and R.	

# Note that in the plot shorter lengths correspond to higher correlations	

numvars <- lapply(weather,is.numeric)    	# Find numeric variables in data set	
weather.num <- na.omit(weather[,numvars==TRUE])	
	
hcPlot <- function(data="numdata"){	
  df <- eval(parse(text=data))	
  cc <- cor(df,use="pairwise",method="pearson")	
  hc <- hclust(dist(cc),method="average")	
  dn <- as.dendrogram(hc)	
  op <- par(mar = c(3, 4, 3, 4.29))	
  plot(dn, horiz = TRUE, nodePar = list(col = 3:2, cex = c(2.0, 0.75), 	
                                        pch = 21:22, bg=  c("light blue", "pink"), lab.cex = 0.75, 	
                                        lab.col = "tomato"), edgePar = list(col = "gray", lwd = 2), xlab="Height")	
  title(main=paste("Variable Correlation Clusters",data,"using Pearson",sep=" "),	
        sub=paste(format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))	
  par(op)	
  return(hc)	
}	
	
hcPlot(data="weather.num")           # Note: name of file must be in quotes!!	

# varclus(), in the Hmisc package, does a hierarchical cluster analysis on variables, using the Hoeffding D statistic, squared Pearson or Spearman (the default) correlations, or proportion of observations for which two variables are both positive as similarity measures. The clustering is done by hclust(). 	

vClus <- varclus(as.matrix(numdata))	
vClus	
plot(vClus)	

