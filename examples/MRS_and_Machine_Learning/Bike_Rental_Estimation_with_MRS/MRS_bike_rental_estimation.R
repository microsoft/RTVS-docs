## Regression: Demand estimation with Microsoft R Server 

# This example demonstrates the feature engineering process for 
# building a regression model to predict bike rental demand. 

# The dataset contains 17,379 rows and 17 columns, each row 
# representing the number of bike rentals within 
# a specific hour of a day in the years 2011 or 2012. 
# Weather conditions (such as temperature, humidity, 
# and wind speed) were included in this raw feature set, 
# and the dates were categorized as holiday vs. 
# weekday etc.
#
# The field to predict is "cnt", which contain a count value 
# ranging from 1 to 977, representing the number
# of bike rentals within a specific hour. The lag features we 
# add in the data set is the number of bikes that 
# were rented in each of the previous 12 hours, 
# which caputures the very recent demand for the bikes.

# The following scripts include five basic steps of building 
# this example using Microsoft R Server.
# This execution might require more than one minute.


### Step 0: Get Started

# Check whether Microsoft R Server (RRE 8.0) is installed.
if (!require("RevoScaleR")) {
  cat("RevoScaleR package does not seem to exist. 
      \nThis means that the functions starting with 'rx' will not run. 
      \nIf you have Microsoft R Server installed, please switch the R engine.
      \nFor example, in R Tools for Visual Studio: 
      \nR Tools -> Options -> R Engine. 
      \nIf Microsoft R Server is not installed, you can download it from: 
      \nhttps://www.microsoft.com/en-us/server-cloud/products/r-server/
      \n")  
  quit()
}

# Initialize some variables.
github <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/MRS_and_Machine_Learning/Datasets/"
inputFileBikeURL <- paste0(github, "Bike_Rental_UCI_Dataset.csv")

# Create a temporary directory to store the intermediate .xdf files.
td <- tempdir()
outFileBike <- paste0(td, "/bike.xdf")
outFileLag <- paste0(td, "/lagData.xdf")


### Step 1: Import the Bike Data

bike <- rxImport(inData = inputFileBikeURL, outFile = outFileBike,
                 overwrite = TRUE,
                 missingValueString = "M", stringsAsFactors = FALSE,
                 # Remove timestamps and all columns that are 
                 # part of the label.
                 varsToDrop = c("instant", "dteday", "casual", "registered"),
                 # Define year, weather conditions and season 
                 # columns as categorical.
                 colInfo = list(yr = list(type = "factor"),
                                weathersit = list(type = "factor"),
                                season = list(type = "factor")))


## Step 2: Feature Engineering

# Add number of bikes that were rented in each of 
# the previous 12 hours as 12 lag features.
computeLagFeatures <- function(dataList) {
  # Total number of lags that need to be added.
  numLags <- length(nLagsVector)
  # Lag feature names as lagN.
  varLagNameVector <- paste("cnt_", nLagsVector, "hour", sep="")  
  
  # Set the value of an object "storeLagData" in the transform environment.
  if (!exists("storeLagData")) 
  {              
    lagData <- mapply(rep, dataList[[varName]][1], times = nLagsVector)
    names(lagData) <- varLagNameVector
    .rxSet("storeLagData", lagData)
  }
  
  if (!.rxIsTestChunk)
  {
    for (iL in 1:numLags)
    {
        # Number of rows in the current chunk.
        numRowsInChunk <- length(dataList[[varName]])
        nlags <- nLagsVector[iL]
        varLagName <- paste("cnt_", nlags, "hour", sep = "")
        # Retrieve lag data from the previous chunk.
        lagData <- .rxGet("storeLagData")
        # Concatenate lagData and the "cnt" feature.
        allData <- c(lagData[[varLagName]], dataList[[varName]])
        # Take the first N rows of allData, where N is 
        # the total number of rows in the original dataList.
        dataList[[varLagName]] <- allData[1:numRowsInChunk]
        # Save last nlag rows as the new lagData to be used 
        # to process in the next chunk. 
        lagData[[varLagName]] <- tail(allData, nlags) 
        .rxSet("storeLagData", lagData)
    }
  }
  return(dataList)                
}

# Apply the "computeLagFeatures" on the bike data.
lagData <- rxDataStep(inData = bike, outFile = outFileLag,
                      transformFunc = computeLagFeatures,
                      transformObjects = list(varName = "cnt",
                                              nLagsVector = seq(12)),
                      transformVars = "cnt", overwrite = TRUE)


### Step 3: Prepare Training and Test Datasets

# Split data by "yr" so that the training data contains records 
# for the year 2011 and the test data contains records for 2012.
rxSplit(inData = lagData,
        outFilesBase = paste0(td, "/modelData"),
        splitByFactor = "yr",
        overwrite = TRUE,
        reportProgress = 0,
        verbose = 0)

# Point to the .xdf files for the training and test set.
train <- RxXdfData(paste0(td, "/modelData.yr.0.xdf"))
test <- RxXdfData(paste0(td, "/modelData.yr.1.xdf"))


## Step 4: Choose and apply a learning algorithm (Decision Forest Regression)

# Build a formula for the regression model and remove the "yr", 
# which is used to split the training and test data.
modelFormula <- formula(train, depVars = "cnt",
                        varsToDrop = c("RowNum", "yr"))

# Fit a Decision Forest Regression model on the training data.
dForest <- rxDForest(modelFormula, data = train,
                     method = "anova", maxDepth = 10, nTree = 50,
                     importance = TRUE, seed = 123)

# Plot a dotchart of the variable importance as measured by 
# the decision forest.
rxVarImpPlot(dForest, main = "Variable Importance of Decision Forest")

# Plot Out-of-bag error rate comparing to the number of trees built 
# in the decision forest model.
plot(dForest, main = "OOB Error Rate vs Number of Trees")


### Step 5: Predict over new data and review the model performance

# Predict the probability on the test dataset.
predict <- rxPredict(dForest, data = test, overwrite = TRUE,
                     computeResiduals = TRUE)

# Calculate three statistical measures: 
# Mean Absolute Error (MAE), 
# Root Mean Squared Error (RMSE), and 
# Relative Absolute Error (RAE).
sum <- rxSummary(~ cnt_Resid_abs + cnt_Resid_2 + cnt_rel,
                 data = predict,
                 summaryStats = "Mean", 
                 transforms = list(cnt_Resid_abs = abs(cnt_Resid), 
                                   cnt_Resid_2 = cnt_Resid^2, 
                                   cnt_rel = abs(cnt_Resid)/cnt)
                )$sDataFrame

# List all measures in a data frame.
measures <- data.frame(MAE = sum[1, 2],
                       RMSE = sqrt(sum[2, 2]),
                       RAE = sum[3, 2])

# Review the measures.
measures
