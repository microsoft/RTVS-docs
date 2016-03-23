## Getting Started with R

### Some Brief History	
# R followed S. The S language was conceived by John Chambers, Rick Becker,
# Trevor Hastie, Allan Wilks and others at Bell Labs in the mid 1970's. 
# S was made publicly available in the early 1980’s. R, which is modeled
# closely on S, was developed by Robert Gentleman and Ross Ihaka in the early 
# 1990's while they were both faculty members at the University of Auckland. 
# R was established as an open source project (www.r-project.org) in 1995. 
# Since 1997 the R project has been managed by the R Core Group. 
# When AT&T spun off Bell Labs in 1996, S was no longer freely available. 
# S-PLUS is a commercial implementation of the S language developed by the 
# Insightful corporation which is now sold by TIBCO software Inc.	

# The R Core Group: http://www.r-project.org/contributors.html  	
# Download R: http://cran.r-project.org/	


### How R is oganized	

# R is an interpreted functional language with objects. The core of 
# R language contains the the data manipulation and statistical functions. 
# Most of R's capabilities are delivered as user contributed packages that 
# may be downloaded from CRAN. R ships with the "base and recommended" 
# packages:	
# http://cran.r-project.org/doc/FAQ/R-FAQ.html#Which-add_002don-packages-exist-for-R_003f  	


###  R RESOURCES	

# What is R? the movie: http://www.youtube.com/watch?v=TR2bHSJ_eck   	
# Search for R topics on the web: http://www.rseek.org  	
# search or R packages: http://www.rdocumentation.org  	
# A list of R Resources: http://www.revolutionanalytics.com/what-is-open-source-r/r-resources.php    	
# Quick R: http://www.statmethods.net/  	
# R Reference Card: http://cran.r-project.org/doc/contrib/Short-refcard.pdf    	
# An online book: http://www.cookbook-r.com/  	
# Hadley Wickham's book, Advanced R: http://adv-r.had.co.nz  	
# CRAN Task Views: http://cran.r-project.org/web/views/    	  	
# Some help with packages: http://crantastic.org/  				                                   	
# The Bioconductor project for genomics: http://www.bioconductor.org/     	


### R Blogs	

# Revolutions blog: http://blog.revolutionanalytics.com/  	
# RBloggers: http://www.r-bloggers.com	


### Getting Help	

# If you are looking for help with technical questions about the language 
# please consult the community site (http://www.r-project.org) for frequently 
# asked questions. Ask for help on one of the several R mailing lists  
# http://www.r-project.org/mail.html or 
# Stack Overflow http://stackoverflow.com/questions/tagged/r  	


### Looking at Packages	

# You can extend the functionality of R by installing and loading packages.
# A package is simply a set of functions, and sometimes data
# Package authors can distribute their work on CRAN,
# https://cran.r-project.org/,
# in addition to other repositories (e.g. BioConductor) and GitHub.
# For a list of contributed packages on CRAN, see https://cran.r-project.org/


# There are several ways to run a script in Visual Studio:
# 1) Line by line: with the cursor at the line, press CTRL-Enter
# 2) Multile lines: select the lines you want to run and press CTRL-Enter
# 3) Entire file: press CTRL-A to select all lines and press CTRL-Enter

# Simple calculation.
2 + 3

# Print a message.
print('Hello, World!')

# To get help on a function, use help(function_name) or ?function_name.
?help
?print

# Save all available installed packages on your machine 
# to variable "packages".
# The variable's values can be viewed in Visual Studio's Variable Explorer
# by clicking on the magnifying button in the Value column.
packages <- installed.packages()

# List all "attached" or loaded packages.
search() 	

# You "attach" a package to make it's functions available 
# using the library() function.
# For example, the "foreign" package comes with R and contains 
# functions to import data  from other systems.
library(foreign)

# You can get help on a package using:
library(help = foreign)

# To install a new package, use install.packages()
# Install the ggplot2 package for its plotting capability.
if (!require("ggplot2"))
    install.packages("ggplot2")

# Then load the package.
library("ggplot2")

# Notice that package:ggplot2 is now added to the search list.
search()


### A Simple Regression Example	

# Look at the data sets that come with the package.
# Note that the results in RTVS may pop up, or pop under, in a new window.
data(package = "ggplot2") 	

# ggplot2 contains a dataset called diamonds.
# Make this dataset available using the data() function.
data(diamonds, package = "ggplot2")

# The following command returns all objects in the "global environment".
# Look for "diamonds" in the results.
# These objects also show up in Visual Studio's Variable Explorer.
ls()

# The str command displays the internal structure of the diamonds dataframe.
# You can also view the internal structure 
# in Visual Studio's Variable Explorer.
str(diamonds)

# Print the first few rows.
# Complete data can be viewed in Visual Studio's Variable Explorer
# by clicking on the magnifying button in the Value column. 
head(diamonds) 

# Print the last 6 lines.	
tail(diamonds)

# Find out what kind of object it is.
# The class info also shows up in Visual Studio's Variable Explorer.
class(diamonds)

# Look at the dimension of the data frame.
# The dim info also shows up in Visual Studio's Variable Explorer.
dim(diamonds)


### Vectorized Code	

# This next bit of code shows off a very powerful feature of the R language: 
# how many functions are "vectorized". The function sapply() takes 
# the function class() that we just used on the data frame and applies it 
# to all of the columns of the data frame.	
# The class info also shows up in Visual Studio's Variable Explorer.
sapply(diamonds, class) # Find out what kind of animals the variables are	


### Plots in R	

# Create a random sample of the diamonds data.
diamondSample <- diamonds[sample(nrow(diamonds), 5000),]
dim(diamondSample)

# R has three systems for static graphics: 
# base graphics, lattice and ggplot2.
# This example shows ggplot2 in action.  

# Set the font size so that it will be clearly legible.
theme_set(theme_gray(base_size = 18))

# Make a scatterplot.
ggplot(diamondSample, aes(x = carat, y = price)) +
    geom_point(colour = "blue")

# Add a log scale.
ggplot(diamondSample, aes(x = carat, y = price)) +
    geom_point(colour = "blue") +
    scale_x_log10()

# Add a log scale for both scales.
# The relationship between price and carat looks 
# to be linear on a log-log scale.
# Note that "Everything is linear if plotted log-log with a fat magic marker."
#   -- http://www.daclarke.org/Humour/Engineering.html"
ggplot(diamondSample, aes(x = carat, y = price)) +
    geom_point(colour = "blue") +
    scale_x_log10() +
    scale_y_log10()


### Linear Regression in R	

# Now, let's build a simple regression model, examine the results of 
# the model and plot the points and the regression line.	

# Build the model to predict price using carat.
model <- lm(log(price) ~ log(carat), data = diamondSample)
#model <- lm(price ~ carat, data = diamondSample)

# Look at the results. 	
summary(model) 

# Extract model coefficients.
coef(model)
coef(model)[1]
exp(coef(model)[1])

# Show the model in a plot.
ggplot(diamondSample, aes(x = carat, y = price)) +
    geom_point(colour = "blue") +
    geom_smooth(method = "lm", colour = "red", size = 2) +
    scale_x_log10() +
    scale_y_log10()


### Regression Diagnostics	

# It is easy to get regression diagnostic plots. The same plot function 
# that plots points either with a formula or with the coordinates also has 
# a "method" for dealing with a model object.	

# Set up for multiple plots on the same figure.
par(mfrow = c(2, 2))

# Look at some model diagnostics.
plot(model, col = "blue") 


### The Model Object	

# Finally, let's look at the model object. R packs everything that goes with 
# the model, the fornula, and results into the object. You can pick out what 
# you need by indexing into the model object.	
str(model)
model$coefficients
coef(model)


### Make prediction for the first several data points.
first <- 221
last <- 231
pred_data <- diamonds[first:last,]
pred <- predict(model, pred_data)
# The weight of each diamond in carats:
diamonds$carat[first:last]
# The actual price:
diamonds$price[first:last]
# The predicted price:
exp(pred)
