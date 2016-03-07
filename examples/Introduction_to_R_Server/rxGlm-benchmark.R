# ----------------------------------------------------------------------------
# Comparison between Microsoft R Server and CRAN R modeling functions
# ----------------------------------------------------------------------------

# This example demonstrates how to fit a logistic regression using CRAN R,
# and how the rxGlm() function is dramatically faster and more scalable

# ---- Using CRAN R functions -------------------------------------------------

# The CRAN R function uses an airline dataset available at
# http://packages.revolutionanalytics.com/datasets/AirOnTimeCSV2012/
# The following code downloads airOT201201.csv

csvFile <- "airOT201201.csv"
if (!file.exists(csvFile))
{
  url <- "https://packages.revolutionanalytics.com/datasets/AirOnTimeCSV2012/airOT201201.csv"
  download.file(url, destfile = csvFile)
}

# Import data into memory
df <- read.csv(csvFile, colClasses = c("DAY_OF_WEEK" = "factor"))

# Check the number of observations
nrow(df)
# 486,133

# Print the variable names
names(df)

# Fit a logistic regression model
# On a system with limited memory this operation could run out of memory
# However, on a bigger machine, this operation can take several minutes
system.time(
  model1 <- glm(ARR_DEL15 ~ ORIGIN + DAY_OF_WEEK + DEP_TIME,
                data = df,
                family = binomial))

# Fit the same model on a smaller set of data, by randomly sampling down
# This should take about 10 seconds to run
sampledata <- df[sample.int(nrow(df), size = 10000),]
nrow(sampledata)
system.time(
  model1 <- glm(ARR_DEL15 ~ ORIGIN + DAY_OF_WEEK + DEP_TIME,
                data = sampledata,
                family = binomial))


# Print information about the model
summary(model1)


# ---- Using Microsoft R Server functions ------------------------------------


# Note: download AirOnTime2012.xdf from http://packages.revolutionanalytics.com/datasets/

xdfFile <- "AirOnTime2012.xdf"
if (!file.exists(xdfFile))
{
  url <- "https://packages.revolutionanalytics.com/datasets/AirOnTime2012.xdf"
  download.file(url, destfile = xdfFile, mode = "wb")
}
xdf <- RxXdfData(xdfFile)

xdf_sub1 <- tempfile(fileext = ".xdf")
rxDataStep(xdf, outFile = xdf_sub1, numRows = 1e6)

# Check the number of observations
rxGetInfo(xdf) # can also use nrow( xdf )
nrow(xdf)
# Number of observations: 6,096,762 

# Print the variable names
rxGetVarInfo(xdf) # can also use names( xdf )

# Set a local parallel compute context
rxSetComputeContext(RxLocalParallel())

# Fit a logistic regression model using rxLogit()
system.time(
  model2 <- rxLogit(ArrDel15 ~ Origin + DayOfWeek + DepTime,
                    data = xdf,
                    blocksPerRead = 25))
# elapsed time: 6.7 seconds

# Print information about the model
summary(model2)

# Fit a logistic regression model using rxGlm()
system.time(
  model3 <- rxGlm(ArrDel15 ~ Origin + DayOfWeek + DepTime,
                  data = xdf,
                  family = binomial,
                  blocksPerRead = 25))
# elapsed time: 9.4 seconds

# Print information about the model
summary(model3)


#  ------------------------------------------------------------------------

# Now create benchmark graphic
# Note: this code loops through several functions that each may take 
# several seconds to complete.
# This can take several minutes to complete the entire cycle


testFunR <- function(nrows)
{
  df <- read.csv(csvFile,
  colClasses = c("DAY_OF_WEEK" = "factor"),
  nrows = nrows)
  system.time(
    glm(ARR_DEL15 ~ ORIGIN + DAY_OF_WEEK + DEP_TIME,
        data = df,
        family = binomial))
}[[3]] 

nrow_R <- c(10e3, 20e3, 50e3, 100e3) # number of rows in data
timing_R <- sapply(nrow_R, testFunR)
timing_R <- data.frame(
  R = "CRAN R glm()",
  nrows = nrow_R,
  time = timing_R)
timing_R

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
                      verbose = 0))[[3]] # extract 3rd element (elapsed time)
}

nrow_MRS <- c(1e6, 2e6, 3e6, 6e6) # number of rows in data
timing_MRS <- sapply(nrow_MRS, testFunMRS)
timing_MRS <- data.frame(
  R = "R Server rxLogit()",
  nrows = nrow_MRS,
  time = timing_MRS)
timing_MRS

timings <- rbind(timing_R, timing_MRS)
library(ggplot2)
ggplot(timings, aes(x = nrows, y = time, col = R)) +
  geom_line() +
  geom_point() +
  scale_color_discrete(NULL) +
  xlab("Number of rows") +
  ylab("Elapsed time (seconds)")



