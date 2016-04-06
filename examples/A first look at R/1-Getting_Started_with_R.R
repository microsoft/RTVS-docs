## Getting Started with R

### Some Brief History

# R followed S. The S language was conceived by John Chambers, Rick Becker,
# Trevor Hastie, Allan Wilks and others at Bell Labs in the mid 1970s. 
# S was made publically available in the early 1980's. R, which is modeled
# closely on S, was developed by Robert Gentleman and Ross Ihaka in the early 
# 1990's while they were both faculty members at the University of Auckland. 
# R was established as an open source project (www.r-project.org) in 1995. 
# Since 1997 the R project has been managed by the R Core Group. 
# When AT&T spun of Bell Labs in 1996, S was no longer freely available. 
# S-PLUS is a commercial implementation of the S language developed by the 
# Insightful corporation which is now sold by TIBCO software Inc.  

# The R Core Group: http://www.r-project.org/contributors.html     
# Download R: http://cran.r-project.org/ 


### How R is organized      

# R is an interpreted functional language with objects. The core of 
# R language contains the the data manipulation and statistical functions. 
# Most of R's capabilities are delivered as user contributed packages that 
# may be downloaded from CRAN.R ships with the "base and recommended" 
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
# The BIOCONDUCTOR PROJECT FOR GENOMICS: http://www.bioconductor.org/     


### R Blogs   

# Revolutions blog: http://blog.revolutionanalytics.com/     
# RBloggers: http://www.r-bloggers.com   


### Getting Help     

# If you are looking for help with technical questions about the language 
# please consult the community site (http://www.r-project.org) for frequently 
# asked questions. Ask for help on one of the several R mailing lists  
# http://www.r-project.org/mail.html or 
# Stack Overflow http://stackoverflow.com/questions/tagged/r     


### Packages used in this set of examples

# Package      | Use
# ----------   | ----------
# ggplot2      | Plots


### Looking at Packages    

# You can extend the functionality of R by installing and loading packages.
# A package is simply a set of functions, and sometimes data
# Package authors can distribute their work on CRAN, https://cran.r-project.org/,
# in addition to other repositors (e.g. BioConductor) and github
# For a list of contributed packages on CRAN, see https://cran.r-project.org/

# List all available installed packages on your machine.
installed.packages()

# List all "attached" or loaded packages.
search()      

# You "attach" a package to make it's functions available, 
# using the library() function.
# For example, the "foreign" package comes with R and contains 
# functions to import data  from other systems.
library(foreign)

# You can get help on a package using:
library(help = foreign)

# To install a new package, use install.packages()
# Install the ggplot2 package for it's plotting capability.
if (!require("ggplot2")){
  install.packages("ggplot2")
}

# Then load the package.
library("ggplot2")
search()
# Notice that package:ggplot2 is now added to the search list.


### A Simple Regression Example   

# Look at the data sets that come with the package.
data(package = "ggplot2")$results
# Note that the results in RTVS may pop up, or pop under, in a new window.

# ggplot2 contains a dataset called diamonds. Make this dataset available using the data() function.
data(diamonds, package = "ggplot2")

# Create a listing of all objects in the "global environment". Look for "diamonds" in the results.
ls()

# Now investigate the structure of diamonds, a data frame with 53,940 observations
str(diamonds)

# Print the first few rows.
head(diamonds) 

# Print the last 6 lines.  
tail(diamonds)

# Find out what kind of object it is.
class(diamonds)

# Look at the dimension of the data frame.
dim(diamonds)


### Plots in R       

# Create a random sample of the diamonds data.
diamondSample <- diamonds[sample(nrow(diamonds), 5000),]
dim(diamondSample)

# R has three systems for static graphics: base graphics, lattice and ggplot2.  
# This example uses ggplot2

# Set the font size so that it will be clearly legible.
theme_set(theme_gray(base_size = 18))

# In this sample you use ggplot2.
ggplot(diamondSample, aes(x = carat, y = price)) +
  geom_point(colour = "blue")

# Add a log scale.
ggplot(diamondSample, aes(x = carat, y = price)) +
  geom_point(colour = "blue") +
  scale_x_log10()

# Add a log scale for both scales.
ggplot(diamondSample, aes(x = carat, y = price)) +
  geom_point(colour = "blue") +
  scale_x_log10() +
  scale_y_log10()

### Linear Regression in R 

# Now, build a simple regression model, examine the results of the model and plot the points and the regression line.  

# Build the model. log of price explained by log of carat. This illustrates how linear regression works. Later we fit a model that includes the remaining variables

model <- lm(log(price) ~ log(carat) , data = diamondSample)       

# Look at the results.     
summary(model) 
# R-squared = 0.9334, i.e. model explains 93.3% of variance

# Extract model coefficients.
coef(model)
coef(model)[1]
exp(coef(model)[1]) # exponentiate the log of price, to convert to original units

# Show the model in a plot.
ggplot(diamondSample, aes(x = carat, y = price)) +
  geom_point(colour = "blue") +
  geom_smooth(method = "lm", colour = "red", size = 2) +
  scale_x_log10() +
  scale_y_log10()


### Regression Diagnostics 

# It is easy to get regression diagnostic plots. The same plot function that plots points either with a formula or with the coordinates also has a "method" for dealing with a model object.   


# Look at some model diagnostics.
# check to see Q-Q plot to see linearity which means residuals are normally distributed

par(mfrow = c(2, 2)) # Set up for multiple plots on the same figure.
plot(model, col = "blue") 
par(mfrow = c(1, 1)) # Rest plot layout to single plot on a 1x1 grid


### The Model Object 

# Finally, let's look at the model object. R packs everything that goes with the model, e.g. the formula and results into the object. You can pick out what you need by indexing into the model object.
str(model)
model$coefficients  # note this is the same as coef(model)

# Now fit a new model including more columns
model <- lm(log(price) ~ log(carat) + ., data = diamondSample) # Model log of price against all columns

summary(model)
# R-squared = 0.9824, i.e. model explains 98.2% of variance, i.e. a better model than previously



# Create data frame of actual and predicted price

predicted_values <- data.frame(
  actual = diamonds$price, 
  predicted = exp(predict(model, diamonds)) # anti-log of predictions
)

# Inspect predictions
head(predicted_values)

# Create plot of actuals vs predictions
ggplot(predicted_values, aes(x = actual, y = predicted)) + 
  geom_point(colour = "blue", alpha = 0.01) +
  geom_smooth(colour = "red") +
  coord_equal(ylim = c(0, 20000)) + # force equal scale
  ggtitle("Linear model of diamonds data")

