## Demonstrates the commonalities and differences beteween functions
## in R, Microsoft R Open (MRO), and Microsoft R Server (MRS).
## Part 1a looks at generalized linear models.

# To learn more about the differences among R, MRO and MRS, refer to:
# https://github.com/lixzhang/R-MRO-MRS

# Check whether Microsoft R Server is installed and load libraries.
# Check whether RevoScaleR is available.
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

# Install ggplot2 if it's not already installed.
if (!require("ggplot2", quietly = TRUE)) install.packages("ggplot2")
library("ggplot2") # used for plotting


## Generalized linear models: glm vs rxGlm

# Check the data.
head(mtcars)

# Check the response variable.
ggplot(mtcars, aes(x=vs)) + 
  geom_histogram(binwidth=.3) +
  ggtitle("Distribution of Response Values")
  
# Fit a model with glm(). This can be run on R, MRO, or MRS.
# Predict V engine vs straight engine with weight and displacement.
logistic1 <- glm(vs ~ wt + disp, data = mtcars, family = binomial)
summary(logistic1)

# Fit the same model with rxGlm() if RevoScaleR is installed.
if (RRE){
  # Check the data.
  head(mtcars)
  
  # Predict V engine vs straight engine with weight and displacement.
  logistic2 <- rxGlm(vs ~ wt + disp, data = mtcars, family = binomial)
  summary(logistic2)
} else {
    cat("-----------------------------------------------------------------\n",
    "rxGlm was not run becauase the RevoScaleR package is not available.")
}
