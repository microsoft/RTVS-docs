# ---	
# title: "4 - Functions"	
# ---	

# The checkpoint function installs all required dependencies (i.e. CRAN packages)
# you need to run the examples.
if (!require("checkpoint", quietly = TRUE))
  install.packages("checkpoint")

# create checkpoint folder
if (!file.exists("~/.checkpoint"))
  dir.create("~/.checkpoint")
library("checkpoint")
checkpoint("2016-01-01")

# "A function is a group of instructions that takes inputs, uses them 
# to compute other values, and returns the result" 
#    - Norm Matloff The Art of R Programming	

### Get Some Data	

aq <- airquality[,1:4]  # Get the first four columns of the data frame	
dim(aq)										
head(aq)	

# Make the aq column of airquality available in the global environment	
attach(aq)	

# Try to get a mean for Ozone.	
mean(Ozone)								# Try to get a mean for Ozone	

# Eliminate NAs from the Ozone vetor and put the non-NA values into OZ	
Oz <- na.omit(Ozone)	
length(Oz)	
mean(Oz)	

# Get help with a function from the console	
help(mean)								# getting help with an R function	
#?mean									    # Same as the above	
example(mean)							# See an example of an R function	


### Writing Functions  	

# Let's write our own mean function  	
jmean <- function(x){	
	m <- sum(x)/length(x)		# where is m?	
	return(m)	
}	
jmean(Oz)
	
# R will throw an error because m is not in the global environment	
m 	

# Try again and improve the formatting	
jmean2 <- function(x){	
	m <- round(sum(x)/length(x),2)	
	return(m)	
}	
jmean2(Oz)	

# Why not give the user more control of the rounding process?	
# he magic 3 dots ... enable arguments to be passed to sub functions  	
jmean3 <- function(x,...){	
	m <- round(sum(x)/length(x),...)	
	return(m)	
  }

#?round						# look to see what parameters round is expecting	
	
jmean3(Oz,3)	
jmean3(Oz)				# the default value for round is 0	
jmean3(Oz,1)	


### Functions calling Functions  	

# How about giving the user a choice about which rounding function to use?  	
# Look at the difference between round() and signif().	

pi	
round(pi,4)	
signif(pi,4)	

# This is the way to have one function call an other function	
jmean4 <- function(x,FUN,...){	
	m <- FUN(sum(x)/length(x),...)	
	return(m)	
}	
jmean4(Oz,round,4)	
jmean4(Oz,signif,4)	


### Functions with Defaults	

# One last try  	
#      - make round the default method of rounding	
#      - make the default number of decimal digits 2  	
jmean5 <- function(x,FUN = round,digits=3){	
	m <- FUN(sum(x)/length(x),digits)	
	return(m)	
}	
jmean5(Oz)	
jmean5(Oz,FUN=signif)	
jmean5(Oz,FUN=signif,digits=4)	


### How to make a function return multiple values	

# A simple function that returns multiple values	
aq.noMV <- na.omit(aq)	
mvsd <- function(x){	
	m <- sapply(x,mean)	
	v <- sapply(x,var)	
	s <- sapply(x,sd)	
	res <- list(m,v,s)	
	names(res) <- c("mean","variance","sd")	
	return(res)	
}	
mvsd(aq.noMV)	


### Clean up the Global Environment	

detach(aq)	# remove the aq data frame variables from the global environment							
rm(aq)			# remove aq from the global environment	

#rm(list=ls())	# Get rid of everything. Be careful with this!!!	

### Some Important,  Helpful Functions	

# Missing Values	
# NA is the way to designate a missiong value as we saw above.	
z <- c(1:3,NA)					
z	

# But, the following logical expression is incomplete, and therefore 
# undecideable, so everything is NA.
z == NA 	

# Here is the proper way to search for NAs 	
zm <- is.na(z)					
zm	

# NaN is not a number	
z1 <- c(z,0/0)				# NaN: not a number	
z1	
is.na(z1)					    # Finds NAs and NaNs	
#	
is.nan(z1)            # Only finds NaNs	


### Getting rid of NAs	

# na.omit removes the entire row cantaining an NA from a data frame	
a <- 1:10	
b <- letters[1:10]	
c <- LETTERS[11:20]	
d <- 100:91	
dF <- data.frame(a,b,c,d)	
names(dF) <- c("v1","v2","v3","v4") # Give names to the variables in the data frame	
dF$v1[3] <- NA	
dF$v2[7] <- NA	
dF	
na.omit(dF)						
