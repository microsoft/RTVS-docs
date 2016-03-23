## Comparison between Microsoft R Server and CRAN R modeling functions

# This example demonstrates how to fit a logistic regression using CRAN R,
# and how the rxGlm() function is dramatically faster and more scalable.

# NOTE: The CRAN portion of this comparison requires about 7GB of RAM.
# If your machine has less, this script will crash.

# Check whether the "RevoScaleR" package is loaded in the current environment.
if (!require("RevoScaleR")) {
    cat("RevoScaleR package does not seem to exist. 
        \nThis means that the functions starting with 'rx' will not run. 
        \nIf you have Microsoft R Server installed, 
        \nplease switch the R engine.
        \nFor example, in R Tools for Visual Studio: 
        \nR Tools -> Options -> R Engine. 
        \nIf Microsoft R Server is not installed, you can download it from: 
        \nhttps://www.microsoft.com/en-us/server-cloud/products/r-server/
        \n")

    quit()
}

# Load "ggplot2" package for visualization.
if (!require("ggplot2", quietly = TRUE)) install.packages("ggplot2")
library("ggplot2") 


### Using CRAN R functions

# The CRAN R function uses an airline dataset available at
# http://packages.revolutionanalytics.com/datasets/AirOnTimeCSV2012/
# The following code downloads airOT201201.csv

csvFile <- "airOT201201.csv"
if (!file.exists(csvFile))
{
    url <- "https://packages.revolutionanalytics.com/datasets/AirOnTimeCSV2012/airOT201201.csv"
    cat("A large file is downloading. It may take several minutes")
    cat(" to complete. Please wait.\n")
    download.file(url, destfile = csvFile)
}

# Import data into memory.
df <- read.csv(csvFile, colClasses = c("DAY_OF_WEEK" = "factor"))

# Check the number of observations.
# Should be 486,133
nrow(df)

# Print the variable names.
names(df)

# Fit a logistic regression model.
# NOTE: On a system with less than 8GB memory this operation 
# could run out of memory.
# If it completes, it may take several minutes.
cat("Please note:\n")
cat("On a system with less than 8GB memory,\n")
cat("this operation could run out of memory. \n")
cat("If it completes, it may take several minutes. \n")
system.time(
  model1 <- glm(ARR_DEL15 ~ ORIGIN + DAY_OF_WEEK + DEP_TIME,
                data = df,
                family = binomial))

# Fit the same model on a smaller set of data, by randomly sampling down.
# This should take about 10 seconds to run.
sampledata <- df[sample.int(nrow(df), size = 10000), ]
nrow(sampledata)
system.time(
  model1 <- glm(ARR_DEL15 ~ ORIGIN + DAY_OF_WEEK + DEP_TIME,
                data = sampledata,
                family = binomial))

# Print information about the model.
summary(model1)


### Use Microsoft R Server functions 

# Note: download AirOnTime2012.xdf from 
# http://packages.revolutionanalytics.com/datasets/

xdfFile <- "AirOnTime2012.xdf"
if (!file.exists(xdfFile))
{
    url <- "https://packages.revolutionanalytics.com/datasets/AirOnTime2012.xdf"
    cat("A large file is downloading. It may take several minutes")
    cat(" to complete. Please wait.\n")
    download.file(url, destfile = xdfFile, mode = "wb")
}
xdf <- RxXdfData(xdfFile)

xdf_sub1 <- tempfile(fileext = ".xdf")
rxDataStep(xdf, outFile = xdf_sub1, numRows = 1e6)

# Check the number of observations.
# You can also use nrow( xdf )
# Number of observations: 6,096,762 
rxGetInfo(xdf) 
nrow(xdf)

# Print the variable names.
# You can also use names( xdf )
rxGetVarInfo(xdf)

# Set a local parallel compute context.
rxSetComputeContext(RxLocalParallel())

# Fit a logistic regression model using rxLogit()
system.time(
  model2 <- rxLogit(ArrDel15 ~ Origin + DayOfWeek + DepTime,
                    data = xdf,
                    blocksPerRead = 25))

# Print information about the model.
summary(model2)

# Fit a logistic regression model using rxGlm()
system.time(
  model3 <- rxGlm(ArrDel15 ~ Origin + DayOfWeek + DepTime,
                  data = xdf,
                  family = binomial,
                  blocksPerRead = 25))

# Print information about the model
summary(model3)


### Now create benchmark graphic

# Note: this code loops through several functions that each may take 
# several seconds to complete.
# This can take several minutes to complete the entire cycle

# Get elapsed time for building Logistic Regression models with different 
# number of rows in data.
testFunR <- function(nrows)
{
  df <- read.csv(csvFile,
                 colClasses = c("DAY_OF_WEEK" = "factor"),
                 nrows = nrows)
  system.time(
    glm(ARR_DEL15 ~ ORIGIN + DAY_OF_WEEK + DEP_TIME,
        data = df,
        family = binomial))[[3]] # extract 3rd element (elapsed time)
} 

# Number of rows in data.
nrow_R <- c(10e3, 20e3, 50e3, 100e3) 
cat("Please note:
The following process may take serveral minutes to complete.
Please wait. \n")
timing_R <- sapply(nrow_R, testFunR)
timing_R <- data.frame(
  R = "CRAN R glm()",
  nrows = nrow_R,
  time = timing_R)

# Output elapsed time for glm models.
timing_R

# Get elapsed time for building rxLogit models with different 
# number of rows in data if RevoScaleR is installed.
testFunMRS <- function(nrows)
{
  xdf_subset <- tempfile(fileext = ".xdf")
  on.exit(file.remove(xdf_subset))
  rxDataStep(xdf, outFile = xdf_subset, numRows = nrows,
  overwrite = TRUE, reportProgress = 1)
  rxSetComputeContext(RxLocalParallel())
  system.time(
    model2 <- rxLogit(ArrDel15 ~ Origin + DayOfWeek + DepTime,
                      data = xdf_subset,
                      blocksPerRead = 25,
                      reportProgress = 1,
                      verbose = 0))[[3]] # 3rd element is elapsed time.
}

nrow_MRS <- c(1e6, 2e6, 3e6, 6e6)
timing_MRS <- sapply(nrow_MRS, testFunMRS)
timing_MRS <- data.frame(
  R = "R Server rxLogit()",
  nrows = nrow_MRS,
  time = timing_MRS)

# Output elapsed time for rxLogit models.
timing_MRS

# Visualize the timing comparison using ggplot2.
timings <- rbind(timing_R, timing_MRS)
ggplot(timings, aes(x = nrows, y = time, col = R)) +
  geom_line() +
  geom_point() +
  scale_color_discrete(NULL) +
  xlab("Number of rows") +
  ylab("Elapsed time (seconds)")



