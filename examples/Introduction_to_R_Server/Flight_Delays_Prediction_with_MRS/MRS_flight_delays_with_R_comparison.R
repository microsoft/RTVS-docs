#####################################################################################################################################
################################ Flight Delay Prediction with Microsoft R Server ####################################################
#####################################################################################################################################
# 
#
# This example demostrates a step-by-step comparison of solving a Machine Learning use case using open
# source R (a.k.a. CRAN R) and Microsoft R Server. The open source R script is available in a GitHub
# repository: 
# https://github.com/Microsoft/RTVS-docs/tree/master/examples/Introduction_to_Machine_Learning_with_R/Flight_Delays_Prediction_with_R.
# 
# In this example, we use historical on-time performance and weather data to predict whether the arrival 
# of a scheduled passenger flight will be delayed by more than 15 minutes.
#
# We approach this problem as a classification problem, predicting two classes -- whether the flight will 
# be delayed, or whether it will be on time. Broadly speaking, in machine learning and statistics, 
# classification is the task of identifying the class or category to which a new observation belongs, on 
# the basis of a training set of data containing observations with known categories. Classification is 
# generally a supervised learning problem. Since this is a binary classification task, there are only two 
# classes.
#
# In this example, we train a model using a large number of examples from historic flight data, along with 
# an outcome measure that indicates the appropriate category or class for each example. The two classes 
# are labeled 1 if a flight was delayed, and labeled 0 if the flight was on time.
#
# The following scripts include five basic steps of building this example using Microsoft R Server.
#
#
#####################################################################################################################################


#---------------------------Step 0: Get Started---------------------------
# Check whether the "RevoScaleR" package is loaded in the current environment.
if (require("RevoScaleR")) {
    library("RevoScaleR") # Load RevoScaleR package from Microsoft R Server.
    message("RevoScaleR package is succesfully loaded.")
} else {
    message("Can't find RevoScaleR package...")
    message("If you have Microsoft R Server installed,")
    message("please switch the R engine")
    message("in R Tools for Visual Studio: R Tools -> Options -> R Engine.")
    message("If Microsoft R Server is not installed,")
    message("please download it from here:")
    message("https://www.microsoft.com/en-us/server-cloud/products/r-server/.")
}

# Initial some variables.
github <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/Datasets/"
inputFileFlightURL <- paste0(github, "Flight_Delays_Sample.csv")
inputFileWeatherURL <- paste0(github, "Weather_Sample.csv")
(if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE))  # create a temporary folder to store the .xdf files.
outFileFlight <- 'tmp/flight2.xdf'
outFileFlight2 <- 'tmp/flight2_2.xdf'
outFileWeather <- 'tmp/weather2.xdf'
outFileWeather2 <- 'tmp/weather2_2.xdf'
outFileOrigin <- 'tmp/originData2.xdf'
outFileDest <- 'tmp/DestData2.xdf'
outFileFinal <- 'tmp/finalData2.xdf'

#---------------------------Step 1: Import Data---------------------------
# Import the flight data.
flight_mrs <- rxImport(inData = inputFileFlightURL, outFile = outFileFlight, overwrite = TRUE,
                       missingValueString = "M", stringsAsFactors = FALSE)

# Review the first 6 rows of flight data.
head(flight_mrs)

# Summary the flight data.
rxSummary(~., data = flight_mrs, blocksPerRead = 2)

# Import the weather dataset and eliminate some features due to redundance.
weather_mrs <- rxImport(inData = inputFileWeatherURL, outFile = outFileWeather,
                        missingValueString = "M", stringsAsFactors = FALSE,
                        varsToDrop = c('Year', 'Timezone', 'DryBulbFarenheit', 'DewPointFarenheit'),
                        overwrite = TRUE)

#---------------------------Step 2: Pre-process Data---------------------------
# Apply some data transformation on the flight data.
flight_mrs <- rxDataStep(inData = flight_mrs,
                         outFile = outFileFlight2,
                         # Remove columns that are possible target leakers from the flight data. 
                         varsToDrop = c('DepDelay', 'DepDel15', 'ArrDelay', 'Cancelled', 'Year'),
                         # Round down scheduled departure time to full hour.
                         transforms = list(CRSDepTime = floor(CRSDepTime/100)),
                         overwrite = TRUE)

# Rename some column names in the weather data to prepare it for merging.
xform2 <- function(dataList) {
  # Create a new column 'DestAirportID' in weather data.
  dataList$DestAirportID <- dataList$AirportID
  # Rename 'AdjustedMonth', 'AdjustedDay', 'AirportID', 'AdjustedHour'.
  names(dataList)[match(c('AdjustedMonth', 'AdjustedDay', 'AirportID', 'AdjustedHour'),
                        names(dataList))] <- c('Month', 'DayofMonth', 'OriginAirportID', 'CRSDepTime')
  # Return the adapted variable list.
  return(dataList)
}
weather_mrs <- rxDataStep(inData = weather_mrs,
                          outFile = outFileWeather2,
                          transformFunc = xform2,
                          transformVars = c('AdjustedMonth', 'AdjustedDay', 'AirportID', 'AdjustedHour'),
                          overwrite = TRUE)

# Concatenate/Merge flight records and weather data.
# 1). Join flight records and weather data at origin of the flight (OriginAirportID).
originData_mrs <- rxMerge(inData1 = flight_mrs, inData2 = weather_mrs, outFile = outFileOrigin,
                          type = 'inner', autoSort = TRUE, decreasing = FALSE,
                          matchVars = c('Month', 'DayofMonth', 'OriginAirportID', 'CRSDepTime'),
                          varsToDrop2 = 'DestAirportID',
                          overwrite = TRUE)

# 2). Join flight records and weather data using the destination of the flight (DestAirportID).
destData_mrs <- rxMerge(inData1 = originData_mrs, inData2 = weather_mrs, outFile = outFileDest,
                        type = 'inner', autoSort = TRUE, decreasing = FALSE,
                        matchVars = c('Month', 'DayofMonth', 'DestAirportID', 'CRSDepTime'),
                        varsToDrop2 = c('OriginAirportID'),
                        duplicateVarExt = c("Origin", "Destination"),
                        overwrite = TRUE)

# Normalize some numerical features and convert some features to be categorical.
finalData_mrs <- rxDataStep(inData = destData_mrs, outFile = outFileFinal,
                            transforms = list(
                              # Normalize some numerical features
                              Visibility.Origin = scale(Visibility.Origin),
                              DryBulbCelsius.Origin = scale(DryBulbCelsius.Origin),
                              DewPointCelsius.Origin = scale(DewPointCelsius.Origin),
                              RelativeHumidity.Origin = scale(RelativeHumidity.Origin),
                              WindSpeed.Origin = scale(WindSpeed.Origin),
                              Altimeter.Origin = scale(Altimeter.Origin),
                              Visibility.Destination = scale(Visibility.Destination),
                              DryBulbCelsius.Destination = scale(DryBulbCelsius.Destination),
                              DewPointCelsius.Destination = scale(DewPointCelsius.Destination),
                              RelativeHumidity.Destination = scale(RelativeHumidity.Destination),
                              WindSpeed.Destination = scale(WindSpeed.Destination),
                              Altimeter.Destination = scale(Altimeter.Destination),
                              
                              # Convert 'OriginAirportID', 'Carrier' to categorical features
                              OriginAirportID = factor(OriginAirportID),
                              Carrier = factor(Carrier)),
                            overwrite = TRUE)


#---------------------------Step 3: Prepare Training and Test Datasets---------------------------
# Randomly split 80% data as training set and the remaining 20% as test set.
rxSplit(inData = outFileFinal,
        outFilesBase = "tmp/modelData",
        outFileSuffixes = c("Train", "Test"),
        splitByFactor = "splitVar",
        overwrite = TRUE,
        transforms = list(splitVar = factor(sample(c("Train", "Test"), size = .rxNumRows, replace = TRUE, prob = c(.80, .20)),
                                            levels = c("Train", "Test"))),
        rngSeed = 17,
        consoleOutput = TRUE)

# Point to the .xdf files for the training and test set.
train <- RxXdfData("tmp/modelData.splitVar.Train.xdf")
test <- RxXdfData("tmp/modelData.splitVar.Test.xdf")

#---------------------------Step 4A: Choose and apply a learning algorithm (Logistic Regression)---------------------------
# Build the formula.
modelFormula <- formula(train, depVars = "ArrDel15", varsToDrop = c("RowNum", "splitVar"))

# Build a Logistic Regression model.
logitModel_mrs <- rxLogit(modelFormula, data = train)

# Review the model results.
summary(logitModel_mrs)

#---------------------------Step 5A: Predict over new data (Logistic Regression)---------------------------
# Predict the probability on the test dataset.
predictLogit_mrs <- rxPredict(logitModel_mrs, data = test, type = "response", predVarNames = "ArrDel15_Pred_Logit", overwrite = TRUE)

# Calculate Area Under the Curve (AUC).
rxAuc(rxRoc("ArrDel15", "ArrDel15_Pred_Logit", predictLogit_mrs))
rxRocCurve("ArrDel15", "ArrDel15_Pred_Logit", data = test,
           title = "ROC curve - Logistic regression")

#---------------------------Step 4B: Choose and apply a learning algorithm (Decision Tree)---------------------------
# Build a decision tree model.
dTree1_mrs <- rxDTree(modelFormula, data = test)

# Find the Best Value of cp for Pruning rxDTree Object.
treeCp_mrs <- rxDTreeBestCp(dTree1_mrs)

# Prune a decision tree created by rxDTree and return the smaller tree.
dTree2_mrs <- prune.rxDTree(dTree1_mrs, cp = treeCp_mrs)

#---------------------------Step 5B: Predict over new data (Decision Tree)---------------------------
# Predict the probability on the test dataset.
predictTree_mrs <- rxPredict(dTree2_mrs, data = test, predVarNames = "ArrDel15_Pred_Tree", overwrite = TRUE)

# Calculate Area Under the Curve (AUC).
rxAuc(rxRoc("ArrDel15", "ArrDel15_Pred_Tree", predictTree_mrs))
<<<<<<< HEAD
rxRocCurve("ArrDel15",
           predVarNames = c("ArrDel15_Pred_Tree", "ArrDel15_Pred_Logit"),
           data = test,
           title = "ROC curve - Logistic regression")
=======
>>>>>>> 5677fd41eb8011dae8e1c0ecf626df3d11cd3dc4
