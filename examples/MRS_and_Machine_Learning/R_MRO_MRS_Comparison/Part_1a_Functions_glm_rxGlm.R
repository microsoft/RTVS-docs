# ----------------------------------------------------------------------------
# purpose:  to demonstrate the commonalities and differences among functions
#           in R, Microsoft R Open (MRO), and Microsoft R Server (MRS)
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# to learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# ----------------------------------------------------------------------------
# check if Microsoft R Server is installed and load libraries
# ----------------------------------------------------------------------------
# to check if RevoScaleR is available
RRE <- require("RevoScaleR") 
if (!RRE)
{
  message(
    "RevoScaleR package does not seem to exist. \n",
    "This means that the functions starting with 'rx' will not run. \n",
    "If you have Microsoft R Server installed, please switch the R engine.\n",
    "For example, in R Tools for Visual Studio: \n",
    "R Tools -> Options -> R Engine. \n",
    "If Microsoft R Server is not installed, you can download it from: \n",
    "https://www.microsoft.com/en-us/server-cloud/products/r-server/")
}

# install a package if it's not already installed
if (!require("ggplot2", quietly = TRUE)) install.packages("ggplot2")
library("ggplot2") # used for plotting

# ----------------------------------------------------------------------------
# glm vs rxGlm
# ----------------------------------------------------------------------------
# check the data
head(mtcars)

# check the response variable
ggplot(mtcars, aes(x=vs)) + 
  geom_histogram(binwidth=.3) +
  ggtitle("Distribution of Response Values")
  
# fit a model with glm(), this can be run on R, MRO, or MRS
# predict V engine vs straight engine with weight and displacement
logistic1 <- glm(vs ~ wt + disp, data = mtcars, family = binomial)
summary(logistic1)

# fit the same model with rxGlm() if RevoScaleR is installed
if (RRE){
  # check the data
  head(mtcars)
  
  # predict V engine vs straight engine with weight and displacement
  logistic2 <- rxGlm(vs ~ wt + disp, data = mtcars, family = binomial)
  summary(logistic2)
} else {
  print("rxGlm was not run becauase the RevoScaleR package is not available")
}
