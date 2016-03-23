## Regression: Demand estimation with Microsoft R Server

# This example a replication of an existing Azure Machine 
# Learning Experiment - Regression: Demand Estimation 
# https://gallery.cortanaanalytics.com/Experiment/Regression-Demand-estimation-4.

# The dataset contains 17,379 rows and 17 columns, 
# each row representing the number of bike rentals within 
# a specific hour of a day in the years 2011 or 2012. 
# Weather conditions (such as temperature, humidity, 
# and wind speed) were included in this raw feature set, 
# and the dates were categorized as holiday vs. 
# weekday etc.

# The field to predict is "cnt", which contain a count value 
# ranging from 1 to 977, representing the number
# of bike rentals within a specific hour.

# We built four models using the same algorithm, 
# but with four different training datasets. The four training 
# datasets that we constructed were all based 
# on the same raw input data, but we added different additional 
# features to each training set.

# Set A = weather + holiday + weekday + weekend features 
# for the predicted day
# Set B = number of bikes that were rented in each of the previous 12 hours
# Set C = number of bikes that were rented in each of the previous 12 days 
# at the same hour
# Set D = number of bikes that were rented in each of the previous 12 weeks 
# at the same hour and the same day

# Each of these feature sets captures different aspects of the problem:
# Feature set B captures very recent demand for the bikes.
# Feature set C captures the demand for bikes at a particular hour.
# Feature set D captures demand for bikes at a particular hour and 
# particular day of the week.

# The four training datasets were built by combining the feature set 
# as follows:
# Training set 1: feature set A only
# Training set 2: feature sets A+B
# Training set 3: feature sets A+B+C
# Training set 4: feature sets A+B+C+D

# The following scripts include five basic steps of building 
# this example using Microsoft R Server.
# This execution might require more than two minutes.


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
github <- "https://raw.githubusercontent.com/brohrer-ms/RTVS-docs/master/examples/MRS_and_Machine_Learning/Datasets/"
inputFileBikeURL <- paste0(github, "Bike_Rental_UCI_Dataset.csv")

# Create a temporary directory to store the intermediate .xdf files.
td <- tempdir()
outFileBike <- paste0(td, "/bike.xdf")
outFileEdit <- paste0(td, "/editData.xdf")
outFileLag <- paste0(td, "/lagData")


### Step 1: Import Data

# Import the bike data.
# Remove timestamps and all columns that are part of the label.
bike_mrs <- rxImport(inData = inputFileBikeURL,
                     outFile = outFileBike, overwrite = TRUE,
                     missingValueString = "M", stringsAsFactors = FALSE,
                     varsToDrop = c("instant", 
                                    "dteday", 
                                    "casual", 
                                    "registered"))

# Edit Metadata: Define year, weather conditions and season columns 
# as categorical.
editData_mrs <- rxFactors(inData = bike_mrs,
                          outFile = outFileEdit,
                          sortLevels = TRUE,
                          factorInfo = c("yr", "weathersit", "season"),
                          overwrite = TRUE)


### Step 2: Feature Engineering

# Create a function to construct lag features for four different aspects. 
computeLagFeatures <- function(dataList) {
    # Total number of lags that need to be added.
    numLags <- length(nLagsVector) 
    for (iL in 1:numLags) {
        nlag <- nLagsVector[iL]
        varLagName <- paste("cnt_", nlag, unit, sep = "")
        numRowsInChunk <- length(dataList[[baseVar]])
        numRowsToRead <- nlag * interval
        numRowsPadding <- 0
        if (numRowsToRead >= .rxStartRow) {
            numRowsToRead <- .rxStartRow - 1
            numRowsPadding <- nlag * interval - numRowsToRead
        }
        # Determine the current row to start processing the data 
        #between chunks.
        startRow <- .rxStartRow - numRowsToRead
        previousRowsDataList <- rxReadXdf(file = .rxReadFileName,
                                          varsToKeep = baseVar,
                                          startRow = startRow,
                                          numRows = numRowsToRead,
                                          returnDataFrame = FALSE)
        paddingRowsDataList <- rxReadXdf(file = .rxReadFileName,
                                         varsToKeep = baseVar,
                                         startRow = 1,
                                         numRows = numRowsPadding,
                                         returnDataFrame = FALSE)
        dataList[[varLagName]] <- c(paddingRowsDataList[[baseVar]],
                                    previousRowsDataList[[baseVar]],
                                    dataList[[baseVar]])[1:numRowsInChunk]
    }
    return(dataList)
}

# Create a function to add lag features a set of columns at a time.
addLag <- function(inputData, outputFileBase) {

    inputFile <- inputData
    outputFileHour <- paste(outputFileBase, "_hour", ".xdf", sep = "")
    outputFileHourDay <- paste(outputFileBase, "_hour_day", ".xdf", sep = "")
    outputFileHourDayWeek <- paste(outputFileBase, "_hour_day_week", 
                                   ".xdf", sep = "")

    # Initialize some fix values.
    hourInterval <- 1
    dayInterval <- 24
    weekInterval <- 168
    previous <- 12

    # Add number of bikes that were rented in each of the previous 12 hours 
    # (for Set B).
    rxDataStep(inData = inputFile, outFile = outputFileHour,
               transformFunc = computeLagFeatures,
               transformObjects = list(baseVar = "cnt",
                                       unit = "hour",
                                       nLagsVector = seq(12),
                                       interval = hourInterval),
               transformVars = c("cnt"), overwrite = TRUE)

    # Add number of bikes that were rented in each of the previous 12 days 
    # at the same hour (for Set C).
    rxDataStep(inData = outputFileHour, outFile = outputFileHourDay,
               transformFunc = computeLagFeatures,
               transformObjects = list(baseVar = "cnt",
                                       unit = "day", nLagsVector = seq(12),
                                       interval = dayInterval),
               transformVars = c("cnt"), overwrite = TRUE)

    # Add number of bikes that were rented in each of the previous 12 weeks 
    # at the same hour and the same day (for Set D).
    rxDataStep(inData = outputFileHourDay, outFile = outputFileHourDayWeek,
               transformFunc = computeLagFeatures,
               transformObjects = list(baseVar = "cnt",
                                       unit = "week",
                                       nLagsVector = seq(12),
                                       interval = weekInterval),
               transformVars = c("cnt"), overwrite = TRUE)

    file.remove(outputFileHour)
    file.remove(outputFileHourDay)

    return(outputFileHourDayWeek)
}

# Set A = weather + holiday + weekday + weekend features for 
# the predicted day.
finalDataA_mrs <- editData_mrs

# Set B, C & D.
finalDataLag_dir <- addLag(inputData = editData_mrs,
                           outputFileBase = outFileLag)
finalDataLag_mrs <- RxXdfData(finalDataLag_dir)


### Step 3: Prepare Training and Test Datasets

# Set A:
# Split Data.
rxSplit(inData = finalDataA_mrs,
        outFilesBase = paste0(td, "/modelDataA"),
        splitByFactor = "yr",
        overwrite = TRUE, reportProgress = 0, verbose = 0)

# Point to the .xdf files for the training and test set.
trainA_mrs <- RxXdfData(paste0(td, "/modelDataA.yr.0.xdf"))
testA_mrs <- RxXdfData(paste0(td, "/modelDataA.yr.1.xdf"))

# Set B, C & D:
# Split Data.
rxSplit(inData = finalDataLag_mrs,
        outFilesBase = paste0(td, "/modelDataLag"), splitByFactor = "yr",
        overwrite = TRUE, reportProgress = 0, verbose = 0)

# Point to the .xdf files for the training and test set.
train_mrs <- RxXdfData(paste0(td, "/modelDataLag.yr.0.xdf"))
test_mrs <- RxXdfData(paste0(td, "/modelDataLag.yr.1.xdf"))

### Step 4: Choose and apply a learning algorithm (Decision Forest Regression)

newDayFeatures <- paste("cnt_", seq(12), "day", sep = "")
newWeekFeatures <- paste("cnt_",  seq(12), "week", sep = "")

# Set A:
# Build a formula for the regression model and remove the "yr", 
# which is used to split the training and test data.
formA_mrs <- formula(trainA_mrs, depVars = "cnt",
                     varsToDrop = c("RowNum", "yr"))

# Fit Decision Forest Regression model.
dForestA_mrs <- rxDForest(formA_mrs, data = trainA_mrs,
                          method = "anova", maxDepth = 10, nTree = 20,
                          importance = TRUE, seed = 123)

# Set B:
# Build a formula for the regression model and remove the "yr", 
# which is used to split the training and test data, and lag features 
# for Set C and D.
formB_mrs <- formula(train_mrs, depVars = "cnt", varsToDrop = c("RowNum", "yr", newDayFeatures, newWeekFeatures))

# Fit Decision Forest Regression model.
dForestB_mrs <- rxDForest(formB_mrs, data = train_mrs,
                          method = "anova", maxDepth = 10, nTree = 20,
                          importance = TRUE, seed = 123)

# Set C:
# Build a formula for the regression model and remove the "yr", 
# which is used to split the training and test data, and lag features 
# for Set D.
formC_mrs <- formula(train_mrs, depVars = "cnt",
                     varsToDrop = c("RowNum", "yr", newWeekFeatures))

# Fit Decision Forest Regression model.
dForestC_mrs <- rxDForest(formC_mrs, data = train_mrs,
                          method = "anova", maxDepth = 10, nTree = 20,
                          importance = TRUE, seed = 123)

# Set D:
# Build a formula for the regression model and remove the "yr", 
# which is used to split the training and test data.
formD_mrs <- formula(train_mrs, depVars = "cnt",
                     varsToDrop = c("RowNum", "yr"))

# Fit Decision Forest Regression model.
dForestD_mrs <- rxDForest(formD_mrs, data = train_mrs,
                          method = "anova", maxDepth = 10, nTree = 20,
                          importance = TRUE, seed = 123)

# Plot four dotchart of the variable importance as measured by 
# the four decision forest models.
par(mfrow = c(2, 2))
rxVarImpPlot(dForestA_mrs, main = "Variable Importance of Set A")
rxVarImpPlot(dForestB_mrs, main = "Variable Importance of Set B")
rxVarImpPlot(dForestC_mrs, main = "Variable Importance of Set C")
rxVarImpPlot(dForestD_mrs, main = "Variable Importance of Set D")

# Plot Out-of-bag error rate comparing to the number of trees build 
# in a decision forest model.
plot(dForestA_mrs, main = "OOB Error Rate vs Number of Trees: Set A")
plot(dForestB_mrs, main = "OOB Error Rate vs Number of Trees: Set B")
plot(dForestC_mrs, main = "OOB Error Rate vs Number of Trees: Set C")
plot(dForestD_mrs, main = "OOB Error Rate vs Number of Trees: Set D")
par(mfrow = c(1, 1))


### Step 5: Predict over new data

# Set A:
# Predict the probability on the test dataset.
rxPredict(dForestA_mrs, data = testA_mrs, 
          predVarNames = "cnt_Pred_A",
          residVarNames = "cnt_Resid_A",
          overwrite = TRUE, computeResiduals = TRUE)

# Set B:
# Predict the probability on the test dataset.
rxPredict(dForestB_mrs, data = test_mrs, 
          predVarNames = "cnt_Pred_B",
          residVarNames = "cnt_Resid_B",
          overwrite = TRUE, computeResiduals = TRUE)

# Set C:
# Predict the probability on the test dataset.
rxPredict(dForestC_mrs, data = test_mrs, 
          predVarNames = "cnt_Pred_C",
          residVarNames = "cnt_Resid_C",
          overwrite = TRUE, computeResiduals = TRUE)

# Set D:
# Predict the probability on the test dataset.
rxPredict(dForestD_mrs, data = test_mrs, 
          predVarNames = "cnt_Pred_D",
          residVarNames = "cnt_Resid_D",
          overwrite = TRUE, computeResiduals = TRUE)

# Prepare outputs
# Set A:
# Calculate three statistical measures: 
# Mean Absolute Error (MAE), 
# Root Mean Squared Error (RMSE), and 
# Relative Absolute Error (RAE).
sumA <- rxSummary(~ cnt_Resid_A_abs + cnt_Resid_A_2 + cnt_rel_A,
                  data = testA_mrs, summaryStats = "Mean", 
                  transforms = list(cnt_Resid_A_abs = abs(cnt_Resid_A), 
                                    cnt_Resid_A_2 = cnt_Resid_A^2, 
                                    cnt_rel_A = abs(cnt_Resid_A)/cnt)
                 )$sDataFrame

## Set B, C & D:
sum <- rxSummary( ~ cnt_Resid_B_abs + cnt_Resid_B_2 + cnt_rel_B +
                 cnt_Resid_C_abs + cnt_Resid_C_2 + cnt_rel_C +
                 cnt_Resid_D_abs + cnt_Resid_D_2 + cnt_rel_D, 
                 data = test_mrs,
                 summaryStats = "Mean", 
                 transforms = list(cnt_Resid_B_abs = abs(cnt_Resid_B), 
                                   cnt_Resid_B_2 = cnt_Resid_B^2, 
                                   cnt_rel_B = abs(cnt_Resid_B)/cnt,
                                   cnt_Resid_C_abs = abs(cnt_Resid_C), 
                                   cnt_Resid_C_2 = cnt_Resid_C^2, 
                                   cnt_rel_C = abs(cnt_Resid_C)/cnt,
                                   cnt_Resid_D_abs = abs(cnt_Resid_D), 
                                   cnt_Resid_D_2 = cnt_Resid_D^2, 
                                   cnt_rel_D = abs(cnt_Resid_D)/cnt)
                 )$sDataFrame

# Add row names.
features <- c("baseline: weather + holiday + weekday + weekend features for the predicted day",
              "baseline + previous 12 hours demand",
              "baseline + previous 12 hours demand + previous 12 days at the same hour",
              "baseline + previous 12 hours demand + previous 12 days at the same hour + previous 12 weeks at the same hour and the same day demand")

# List all measures in a data frame.
measures <- data.frame(Features = features,
                       MAE = c(sumA[1, 2], sum[1, 2], sum[4, 2], sum[7, 2]),
                       RMSE = c(sqrt(sumA[2, 2]), sqrt(sum[2, 2]),
                                sqrt(sum[5, 2]), sqrt(sum[8, 2])),
                       RAE = c(sumA[3, 2], sum[3, 2], sum[6, 2], sum[9, 2]))

# Review the measures.
measures
