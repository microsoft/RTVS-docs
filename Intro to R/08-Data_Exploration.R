# ---	
# title: "8 - Data Exploration"	
# author: "Joseph Rickert"	
# date: "Wednesday, August 27, 2014"	
# output: html_document	
# ---	
# In this section we will show off some R features for exploring data using plots from various contributed packages.	


(if (!require("Hmisc")) install.packages("Hmisc"))	
library("Hmisc")  		                  # for describe()	
(if (!require("fBasics")) install.packages("fBasics"))
library("fBasics")			
(if (!require("gplots")) install.packages("gplots"))
library("gplots")                       # for barplot	
(if (!require("ggplot2")) install.packages("ggplot2"))
library("ggplot2")                      # for boxplots	
(if (!require("ellipse")) install.packages("ellipse"))
library("ellipse")		                  # for correlation plot	
(if (!require("rattle")) install.packages("rattle"))
library("rattle")                       # for the weather data set	

### The Weather Data	
# We will use the weather data set that is included in the rattle package. First we fetch the data from the package and then write it to disk in the working directory. After that, we can read the data directly from disk.	

data(weather)  # load in the weather data set from the rattle package	
# Write the weather data set to disk	
name <- "weather.csv"                 # name the the disk file	
dataDir <- getwd()                    # Set the directory	
file <- file.path(dataDir,name)        # Construct the file path	
write.table(weather,file,row.names=FALSE,sep=",")  # write to disk	
# weather <- read.table(file,header=TRUE,sep=",")  # read the data from disk	
# weather <- read.csv(file)           # read.csv is a wrapper function for write table	
#	
head(weather)                         # Look at the data	
weather <- weather[,-c(1,2)]          # Drop the first two columns	

### Numerical Summaries	
# We will begin by getting numerical summaries for some variables	

summary(weather)                      # Get a summary 	
describe(weather)                     # Get another summary	
# 	
nm <- names(weather)	
ind <- which(nm=="Sunshine"|nm=="WindGustSpeed"|nm=="WindSpeed9am"|nm=="WindSpeed3pm")	
skewness(weather[,ind],na.rm=TRUE)  # > 1 means big skew	
kurtosis(weather[,ind],na.rm=TRUE)  # > 1 means spikey peak	

### Bar Plot	
# We are eventually going to look at some machine learning algorithms with this data set. Our "target" variable for predictions will be the binary variable, RainTomorrow. So let's produce a bar plot to have a look at it.  The 'gplots' package provides the 'barplot2' function. First, we generate the summary data for plotting.	

ds <- summary(na.omit(weather$RainTomorrow))	
# Plot the data.	
bp <-  barplot2(ds, beside=TRUE, ylab="Frequency", xlab="RainTomorrow", ylim=c(0, max(ds)+15), col="blue")	
text(bp, ds+9, ds)  								  # Add the actual frequencies to the plot	

### Histograms	
# We will build a little function to generate a custom histogram	

attach(weather)										             # make the columns of weather available in the global environment	
jhist <- function(var){	
	        hs <- hist(var,												# plot histogram	
				  main=substitute(paste("Distribution of ",var)),  # title with variable name	
				  xlab=substitute(var),							    # x-axis label with variable name	
					ylab="Frequency",								      # y-axis title	
	        col="grey90",									        # color of histogram	
					ylim=c(0, 90),									      # limits of histogram	
					breaks="fd",										      # use the Freedman-Diaconis algorithm for breakpoints	
 					border=TRUE)										      # set border	
			    dens <- density(var, na.rm=TRUE)			# kernel density estimation	
			    rs <- max(hs$counts)/max(dens$y)			# compute scale factor for density	
			    lines(dens$x, dens$y*rs,							# plot density curve	
				  type="l",												      # plot density as a solid line	
				  col="blue")           								# set the colors	
			    rug(var,col="red")										# Add a rug to the plot	
}	
	
par(mfrow=c(2,2))								                # Put 4 plots on the same graph	
jhist(Sunshine)	
jhist(WindGustSpeed)	
jhist(WindSpeed9am)	
jhist(WindSpeed3pm)	
	
detach(weather)                                 # remove weather variables from environment	

# Next, we will xonstructa Panel Histogram to look at pairwise correlations. The code for this example comes from page 124 of the book: Data Mining with R and Rattle http://amzn.to/1qzExMc	

panel.hist <- function(x,...)	
{	
	usr <- par("usr"); on.exit(par(usr))	
	par(usr=c(usr[1:2],0,1.5))	
	h <- hist(x,plot=FALSE)	
	breaks <-h$breaks; nB <- length(breaks)	
	y <- h$counts; y <- y/max(y)	
	rect(breaks[-nB],0,breaks[-1],y, col="grey90",...)	
}	
	
panel.cor <- function(x,y,digits=2,prefix="",cex.cor,...)	
{	
	usr <- par("usr"); on.exit(par(usr))	
	par(usr = c(0,1,0,1))	
	r <- cor(x,y,use="complete")	
	txt <- format(c(r,0.123456789),digits=digits)[1]	
	txt <- paste(prefix,txt,sep="")	
	if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)	
	text(0.5,0.5,txt)	
}	
# Pick out the variables to put in the panels	
nm <- names(weather)	
vars <- which(nm=="Rainfall"|nm=="Sunshine"|nm=="WindGustDir"|	
	            nm=="WindGustSpeed"|nm=="Humidity3pm"|nm=="RainTomorrow") 	
# Plot	
pairs(weather[,vars],diag.panel=panel.hist,upper.panel=panel.smooth,lower.panel=panel.cor)	

### Boxplots	
# Let's have a look at the distribution of wind spped by direction.	

df <- na.omit(weather)              # build a data frame for plotting without NAs	
b <- ggplot(df,aes(factor(WindGustDir),WindGustSpeed))	
b + geom_boxplot() +	
     xlab("Wind Direction") +	
   theme(axis.text.x=element_text(angle=-90))+	
     ylab("Wind Speed M/Hr") + 	
     ggtitle("Wind Speed Variation")	

### Correlations	
# The 'ellipse' package provides the 'plotcorr' function. Correlations work for numeric variables only.	

# to get bick out the numeric variables from weather you can type the names in by hand	
# numeric <- c("MinTemp", "MaxTemp", "Rainfall", "Evaporation",	
#               "Sunshine", "WindGustSpeed", "WindSpeed9am", "WindSpeed3pm",	
#               "Humidity9am", "Humidity3pm", "Pressure9am", "Pressure3pm",	
#               "Cloud9am", "Cloud3pm", "Temp9am", "Temp3pm")	
# 	
# or try something like this:	
nvars <- names(weather[,sapply(weather,is.numeric)==TRUE])   # Can you unpack this?	
nvars <- nvars[-17]	
corr <- cor(weather[,nvars], use="pairwise", method="pearson")	
ord <- order(corr[1,])            # Order the correlations by their strength.	
corr <- corr[ord, ord]	
print(corr)	
par(mfrow=c(1,1))	
plotcorr(corr, col=colorRampPalette(c("red", "white", "blue"))(11)[5*corr + 6])	
    title(main="Correlation weather.csv using Pearson",	
    sub=paste(format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))	

# Finally, we will look at correlations among missing values. na.omit removes rows contianing NAs, The row numbers of the cases form the "na.action" attribute of the result, of class "omit". So na.rows below contains the row numbers of the missing data points	

na.rows <- attr(na.omit(t(weather)), "na.action")	
corr <- cor(is.na(weather[na.rows]), use="pairwise", method="pearson")	
ord <- order(corr[1,])            # Order the correlations by their strength.	
corr <- corr[ord,ord]	
print(corr)	
cat('\nCount of missing values:\n')	
print(apply(is.na(weather[na.rows]),2,sum))	
cat('\nPercent missing values:\n')	
print(100*apply(is.na(weather[na.rows]), 2,sum)/nrow(weather))	
# 	
plotcorr(corr, col=colorRampPalette(c("red", "white", "blue"))(11)[5*corr + 6])	
title(main="Correlation of Missing Values\nweather.csv using Pearson",	
    sub=paste(format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))	


