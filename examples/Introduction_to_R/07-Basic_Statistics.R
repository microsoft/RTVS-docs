# ---	
# title: "7 - Basic Statistics"	
# ---	

# The checkpoint function installs all required dependencies (i.e. CRAN packages)
# you need to run the examples.
if (!require(checkpoint, quietly = TRUE))
  install.packages("checkpoint")
library(checkpoint)
checkpoint("2016-01-01")


### Descriptive Statistics	
# There are countless examples of doing simple, descriptive statistics with R on the web, for example:	
# http://www.statmethods.net/stats/descriptives.html	
# http://www.r-tutor.com/elementary-statistics	

(if (!require("boot")) install.packages("boot"))
library("boot")


# Here are just a few examples:	

df <- iris  				# Fisher's famous iris data set	
plot(df)	
head(df)	
sl <- iris$Sepal.Length	
pl <- iris$Petal.Length	
mean(sl)					# mean	
var(sl)						# variance	
sd(sl)						# standard deviation	
median(sl)				# median	
quantile(sl)			# quantiles at c(0,.25,.5,.75,1)	
min(sl)						# min	
max(sl)						# max	
cor(sl,pl)				# correlation	
t.test(sl,mu=.5)	# one-sided t-test	
t.test(sl,pl)			# two-sided t test   	

### Simulation	
# The basis for simulation and computational statistics is the ability to draw pweud0-random samples from various probability distributions. R has extensive capabilities to do this. For most distributions R provides four functions which are illustrated here for the Normal Distribution.	

rnorm(10,0,1)           # generate 10 random numbers from a normal distribution with mean = 0 and sd = 1 	
pnorm(2)                # P(x <= 2) = the CDF for standard normal distribution	
qnorm(.9772499)         # Find the quantile: q = qnorm(x) i.e. P(x <= q) = p	
dnorm(0)                # The value of the density function at 0	

# You can easily get randow draws from the following distributions in a manner similar to rnorm(10,0,1) above.	

# RANDOM DRAWS | Distribution	
# ----------------|------------	
# rnorm(x,mean,sd)|Normal	
# rlnorm(x,mean,sd)|Lognormal	
# rt(x,df)|Student's t	
# rf(x,n1,n1)|F distribution	
# rchisq(x,df)|Chi-squared	
# rbinom(x,n,p)|Binomial	
# rpois(x,lambda)|Poisson	
# runif(x,min,max)|Uniform	
# rexp(x,rate)|Exponential	
# rgamma(x,shape,scale)|Gamma	
# rbeta(x,a,b)|Beta	

# This next bit of code draws random numbers from a gamma distribution and plots the results.	

par(mfrow=c(2,2))	
n <- 10000	
shape <- 2	
scale <- 2	
y <- rgamma(n,shape,scale)	
hist(y, freq = FALSE, col = "yellow",ylim=c(0,.8))	
fd <- function(y)dgamma(y,shape,scale)	
curve(fd, col = 2, add = TRUE)	
fcdf <- function(y)pgamma(y,shape,scale)	
curve(fcdf,col="red",main="Gamma(2,2) CDF")	
boxplot(y,col="blue",main="Boxplot")  			# Look at a boxplot	
plot(density(y),col="blue",main="Gamma Density")    # Draw a kernel density plot	
rug(y,col="red")	

### Bootstrapping	
# To get a flavor for what it is like to do statistics in R we will get a bootstrap estimate for the standard error of the median. First, we will wirte a simple function that computes the bootstrap from scratch, then we will use the boot package. The example comes from the UCLA online statistics pages which have many fine examples of doing statistics with R.	
# http://statistics.ats.ucla.edu/stat/r/library/bootstrap.htm	

# This is an example of a non-parametric bootstrap procedure. We will use the Airquality data set again.	


aq <- airquality[,1:4]                 # Get the first four columns									
head(aq)	
Oz <- as.vector(na.omit(aq$Ozone))     # Remove NAs	
set.seed(123)                          # Set the seed to make the simlation repeatable	
b.median <- function(data, R) {	
    resamples <- lapply(1:R, function(i) sample(data, replace=T))	
    r.median <- sapply(resamples, median)	
    std.err <- sqrt(var(r.median))	
    list(resamples=resamples, medians=r.median,std.err=std.err)   	
}	
mb <- b.median(Oz,1000)	
hist(mb$medians,xlab="medians",ylab="Counts",main="Bootstrapped Medians",col="yellow")	
head(mb$medians)	
mb$std.err	

# Now, we will use functions from the boot package. The first thing to do is to write a function to encapsulate the statistic to bootstrap.   	

b.med <- function(data, indices) {	
  	d <- data[indices] # allows boot to select sample	
		m <- median(d)	
		return(m)	
}	
# use b.median to compute 1,000 bootstrap samples with statistics 	
res.med <- boot(data=Oz, statistic=b.med,R=1000)	
res.med	

# For one final example, we use the boot function to bootstrap the standard of the R2 value in a linear regression. First, we do the regression to set the context and then get the standard error for R Squared.   	

form <- formula(Ozone ~ Solar.R + Wind + Temp)	
fit <- lm(form, data=aq)	
summary(fit)	
#	
R2 <- function(formula, data, indices) {	
  	d <- data[indices,] # allows boot to select sample	
		fit <- lm(formula, data=d)	
		return(summary(fit)$r.square)	
}	
# bootstrapping with 1000 replications	
results <- boot(data=aq, statistic=R2,R=1000, formula=form)	
results                       # Print results	
plot(results)                 # Plot the bootstrap values	
boot.ci(results,type="bca")   # Calculate the 95% confidence interval	
	

# For more on bootstrapping have a look at:	
# http://www.statmethods.net/advstats/bootstrapping.html	




