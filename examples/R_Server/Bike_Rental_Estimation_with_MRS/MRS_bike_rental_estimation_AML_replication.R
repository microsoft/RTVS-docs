##############################################################################################################
##################### Regression: Demand estimation with Microsoft R Server ##################################
##############################################################################################################
# 
#
# This example a replication of an existing Azure Machine Learning Experiment - Regression: Demand Estimation 
# https://gallery.cortanaanalytics.com/Experiment/Regression-Demand-estimation-4
#
# The dataset contains 17,379 rows and 17 columns, each row representing the number of bike rentals within 
# a specific hour of a day in the years 2011 or 2012. Weather conditions (such as temperature, humidity, 
# and wind speed) were included in this raw feature set, and the dates were categorized as holiday vs. 
# weekday etc.
#
# The field to predict is "cnt", which contain a count value ranging from 1 to 977, representing the number
# of bike rentals within a specific hour.
#
# The following scripts include five basic steps of building this example using Microsoft R Server.
##############################################################################################################



# Initial some variables.
inputFileBikeURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/R_Server/Bike_Rental_Estimation_with_MRS/Bike%20Rental%20UCI%20dataset.csv"
inputFileBike <- "Bike Rental UCI dataset.csv"
outFileBike <- "bike.xdf"
outFileEdit <- "editData.xdf"
outFileLag <- "lagData"
outFileTrainA <- "trainDataA.xdf"
outFileTestA <- "testDataA.xdf"
outFileTrain <- "trainData.xdf"
outFileTest <- "testData.xdf"

# Stop Report Progress.
rxOptions(reportProgress = 0)


#### Step 1: Import Data.

# Import the bike data.
# Remove timestamps and all columns that are part of the label (casual and registered columns).
bike_mrs <- rxImport(inData = inputFileBikeURL, outFile = outFileBike,
                     missingValueString = "M", stringsAsFactors = FALSE,
                     varsToDrop = c("instant", "dteday", "casual", "registered"))

# Edit Metadata: Definite year, weather conditions and season columns as categorical.
editData_mrs <- rxFactors(inData = bike_mrs, outFile = outFileEdit, sortLevels = TRUE,
                          factorInfo = c("yr", "weathersit", "season"), overwrite = TRUE)


#### Step 2: Feature Engineering.

# Create a function to compute lag features.
computeLagFeatures <- function (dataList) {   
  numLags <- length(nLagsVector)
  for (iL in 1:numLags)
  {
    nlag <- nLagsVector[iL]
    varLagName <- paste("demand.",nlag,unit,sep="")
    numRowsInChunk <- length(dataList[[baseVar]])
    numRowsToRead <- nlag * interval
    numRowsPadding <- 0
    if (numRowsToRead >= .rxStartRow)
    {
      numRowsToRead <- .rxStartRow - 1
      numRowsPadding <- nlag * interval - numRowsToRead
    }
    startRow <- .rxStartRow - numRowsToRead
    previousRowsDataList <- RevoScaleR::rxReadXdf(file = .rxReadFileName,
                                                  varsToKeep = baseVar,
                                                  startRow = startRow, numRows = numRowsToRead,
                                                  returnDataFrame = FALSE)
    paddingRowsDataList <- RevoScaleR::rxReadXdf(file=.rxReadFileName,
                                                 varsToKeep = baseVar,
                                                 startRow = 1, numRows = numRowsPadding,
                                                 returnDataFrame = FALSE)
    dataList[[varLagName]] <- c(paddingRowsDataList[[baseVar]], previousRowsDataList[[baseVar]], dataList[[baseVar]])[1:numRowsInChunk]	
  }
  return(dataList)
}

# Create a function to add lag features a set of columns at a time.
addLag <- function(inputData, outputFileBase) {
  
  inputFile <- inputData
  outputFileHour <- paste(outputFileBase, "_hour",".xdf",sep="")
  outputFileHourDay <- paste(outputFileBase, "_hour_day",".xdf",sep="")
  outputFileHourDayWeek <- paste(outputFileBase, "_hour_day_week",".xdf",sep="")
  
  
  # Initialize some fix values.
  hourInterval <- 1
  dayInterval <- 24
  weekInterval <- 168
  previous <- 12
  
  # Add number of bikes that were rented in each of the previous 12 hours (for Set B).
  rxDataStep(inData = inputFile,outFile = outputFileHour, transformFunc=computeLagFeatures,
             transformObjects = list(baseVar = "cnt", unit = "hour",nLagsVector=seq(12), 
                                     interval = hourInterval),
             transformVars = c("cnt"), overwrite=TRUE)
  
  # Add number of bikes that were rented in each of the previous 12 days at the same hour (for Set C).
  rxDataStep(inData = outputFileHour,outFile = outputFileHourDay, transformFunc=computeLagFeatures,
             transformObjects = list(baseVar = "cnt", unit = "day",nLagsVector=seq(12), 
                                     interval = dayInterval),
             transformVars = c("cnt"), overwrite=TRUE)
  
  # Add number of bikes that were rented in each of the previous 12 weeks at the same hour and the same day (for Set D).
  rxDataStep(inData = outputFileHourDay,outFile = outputFileHourDayWeek, transformFunc=computeLagFeatures,
             transformObjects = list(baseVar = "cnt", unit = "week",nLagsVector=seq(12), 
                                     interval = weekInterval),
             transformVars = c("cnt"), overwrite=TRUE)
  
  file.remove(outputFileHour)
  file.remove(outputFileHourDay)
  
  return(outputFileHourDayWeek)
}

# Set A = weather + holiday + weekday + weekend features for the predicted day.
finalDataA_mrs <- editData_mrs

# Set B, C & D.
finalDataLag_dir <- addLag(inputData = editData_mrs, outputFileBase = outFileLag)
finalDataLag_mrs <- RxXdfData(finalDataLag_dir)


#### Step 3: Prepare Training and Test Datasets.

## Set A:
# Split Data.
rxSplit(inData = finalDataA_mrs, outFilesBase = "modelDataA", splitByFactor = "yr",
        overwrite = TRUE, reportProgress = 0, verbose = 0)
# Remove "yr" column since it is not useful for prediction.
trainA_mrs <- rxDataStep("modelDataA.yr.0.xdf", outFileTrainA, varsToDrop = "yr", overwrite = TRUE)
testA_mrs <- rxDataStep("modelDataA.yr.1.xdf", outFileTestA, varsToDrop = "yr", overwrite = TRUE)

## Set B, C & D:
# Split Data.
rxSplit(inData = finalDataLag_mrs, outFilesBase = "modelDataLag", splitByFactor = "yr",
        overwrite = TRUE, reportProgress = 0, verbose = 0)
# Remove "yr" column since it is not useful for prediction.
train_mrs <- rxDataStep("modelDataLag.yr.0.xdf", outFileTrain, varsToDrop = "yr", overwrite = TRUE)
test_mrs <- rxDataStep("modelDataLag.yr.1.xdf", outFileTest, varsToDrop = "yr", overwrite = TRUE)
# Duplicate the test file for Set B, C, D.
file.rename('testData.xdf', 'testDataB.xdf')
file.copy('testDataB.xdf', 'testDataC.xdf')
file.copy('testDataC.xdf', 'testDataD.xdf')


#### Step 4: Choose and apply a learning algorithm (Decision Forest Regression).

newDayFeatures <- paste("demand", ".", seq(12), "day", sep = "")
newWeekFeatures <- paste("demand", ".", seq(12), "week", sep = "")

## Set A:
# Build the formula.
allvarsA_mrs <- names(trainA_mrs)
xvarsA_mrs <- allvarsA_mrs[allvarsA_mrs != "cnt"]
formA_mrs <- as.formula(paste("cnt", "~", paste(xvarsA_mrs, collapse = "+")))
# Fit Decision Forest Regression model.
dForestA_mrs <- rxDForest(formA_mrs, data = "trainDataA.xdf", importance = TRUE, seed = 123)

## Set B:
# Build the formula.
allvarsB_mrs <- names(train_mrs)[!(names(train_mrs) %in% c(newDayFeatures, newWeekFeatures))]
xvarsB_mrs <- allvarsB_mrs[allvarsB_mrs != "cnt"]
formB_mrs <- as.formula(paste("cnt", "~", paste(xvarsB_mrs, collapse = "+")))
# Fit Decision Forest Regression model.
dForestB_mrs <- rxDForest(formB_mrs, data = "trainData.xdf", importance = TRUE, seed = 123)

## Set C:
# Build the formula.
allvarsC_mrs <- names(train_mrs)[!(names(train_mrs) %in% c(newWeekFeatures))]
xvarsC_mrs <- allvarsC_mrs[allvarsC_mrs != "cnt"]
formC_mrs <- as.formula(paste("cnt", "~", paste(xvarsC_mrs, collapse = "+")))
# Fit Decision Forest Regression model.
dForestC_mrs <- rxDForest(formC_mrs, data = "trainData.xdf", importance = TRUE, seed = 123)

## Set D:
# Build the formula.
allvarsD_mrs <- names(train_mrs)
xvarsD_mrs <- allvarsD_mrs[allvarsD_mrs != "cnt"]
formD_mrs <- as.formula(paste("cnt", "~", paste(xvarsD_mrs, collapse = "+")))
# Fit Decision Forest Regression model.
dForestD_mrs <- rxDForest(formD_mrs, data = "trainData.xdf", importance = TRUE, seed = 123)


#### Step 5: Predict over new data.

## Set A:
# Predict the probability on the test dataset.
predictA_mrs <- rxPredict(dForestA_mrs, data = 'testDataA.xdf', overwrite = TRUE, computeResiduals = TRUE)
scoreA <- rxXdfToDataFrame(predictA_mrs)

## Set B:
# Predict the probability on the test dataset.
predictB_mrs <- rxPredict(dForestB_mrs, data = 'testDataB.xdf', overwrite = TRUE, computeResiduals = TRUE)
scoreB <- rxXdfToDataFrame(predictB_mrs)

## Set C:
# Predict the probability on the test dataset.
predictC_mrs <- rxPredict(dForestC_mrs, data = 'testDataC.xdf', overwrite = TRUE, computeResiduals = TRUE)
scoreC <- rxXdfToDataFrame(predictC_mrs)

## Set D:
# Predict the probability on the test dataset.
predictD_mrs <- rxPredict(dForestD_mrs, data = 'testDataD.xdf', overwrite = TRUE, computeResiduals = TRUE)
scoreD <- rxXdfToDataFrame(predictD_mrs)


#### Prepare outputs.

# Mean Absolute Error:
mae <- function(df) {
  mean(abs(df$cnt_Resid))
}
# Root Mean Squared Error:
rmse <- function(df) {
  sqrt(mean(df$cnt_Resid ^ 2))
}
# Relative Absolute Error:
rae <- function(df) {
  mean(abs(df$cnt_Resid) / df$cnt)
}

# Add row names.
features <- c("baseline: weather + holiday + weekday + weekend features for the predicted day",
              "baseline + previous 12 hours demand",
              "baseline + previous 12 hours demand + previous 12 days at the same hour",
              "baseline + previous 12 hours demand + previous 12 days at the same hour + previous 12 weeks at the same hour and the same day demand")

outputs <- data.frame(Features = features,
                      MAE = c(mae(scoreA), mae(scoreB), mae(scoreC), mae(scoreD)),
                      RMSE = c(rmse(scoreA), rmse(scoreB), rmse(scoreC), rmse(scoreD)),
                      RAE = c(rae(scoreA), rae(scoreB), rae(scoreC), rae(scoreD)))

# View model performance comparison.
outputs


#### Close Up: Remove all .xdf files in the current directory.
rmFiles <- list.files(pattern = "\\.xdf")
file.remove(rmFiles)
