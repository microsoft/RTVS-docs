#########################################################################################################
####################### Flight Delay Prediction with Microsoft R Server #################################
#########################################################################################################
# 
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
#########################################################################################################


# Initial some variables.
inputFileFlightURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/R_Server/Flight_Delays_Prediction_with_MRS/Flight_Delays_Sample.csv"
inputFileWeatherURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/R_Server/Flight_Delays_Prediction_with_MRS/Weather_Sample.csv"
inputFileFlight <- "Flight_Delays_Sample.csv"
inputFileWeather <- "Weather_Sample.csv"
outFileFlight <- 'flight.xdf'
outFileWeather <- 'weather.xdf'
outFileOrigin <- 'originData.xdf'
outFileDest <- 'DestData.xdf'


#### Step 1: Import Data
# Import the flight data.
flight_mrs <- rxImport(inData = inputFileFlightURL, outFile = outFileFlight,
                       missingValueString = "M", stringsAsFactors = FALSE,
                       # Remove columns that are possible target leakers from the flight data.
                       varsToDrop = c('DepDelay', 'DepDel15', 'ArrDelay', 'Cancelled', 'Year'),
                       # Definite "Carrier" as categorical.
                       colInfo = list(Carrier = list(type = "factor")),
#                                       OriginAirportID = list(type = "factor"),
#                                       DestAirportID = list(type = "factor")),
                       # Round down scheduled departure time to full hour.
                       transforms = list(CRSDepTime = floor(CRSDepTime/100)),  
                       overwrite = TRUE)

# Review the first 6 rows of flight data.
head(flight_mrs)

# Summary the flight data.
rxSummary(~., data = flight_mrs, blocksPerRead = 2)

# Import the weather data.
xform <- function(dataList) {
  featureNames <- c("Visibility", "DryBulbCelsius", "DewPointCelsius", "RelativeHumidity", "WindSpeed", "Altimeter")
  dataList[featureNames] <- lapply(dataList[featureNames], scale)
  return(dataList)
}
weather_mrs <- rxImport(inData = inputFileWeatherURL, outFile = outFileWeather,
                        missingValueString = "M", stringsAsFactors = FALSE,
                        # Eliminate some features due to redundance.
                        varsToDrop = c('Year', 'Timezone', 'DryBulbFarenheit', 'DewPointFarenheit'),
                        # Create a new column 'DestAirportID' in weather data.
                        transforms = list(DestAirportID = AirportID),
                        # Definite AirportID and DestAirportID as categorical.
#                         colInfo = list(AirportID = list(type = "factor"),
#                                        DestAirportID = list(type = "factor")),
                        # Normalize some numerical features.
                        transformFunc = xform,  
                        transformVars = c("Visibility", "DryBulbCelsius", "DewPointCelsius", "RelativeHumidity", "WindSpeed", "Altimeter"),
                        overwrite = TRUE)

# Review the variable information of weather data.
rxGetVarInfo(weather_mrs)

#### Step 2: Pre-process Data.
# Rename some column names in the weather data to prepare it for merging.
newVarInfo <- list(AdjustedMonth = list(newName = "Month"),
                   AdjustedDay = list(newName = "DayofMonth"),
                   AirportID = list(newName = "OriginAirportID"),
                   AdjustedHour = list(newName = "CRSDepTime"))
rxSetVarInfo(varInfo = newVarInfo, data = weather_mrs)

# Concatenate/Merge flight records and weather data.
# 1). Join flight records and weather data at origin of the flight (OriginAirportID).
originData_mrs <- rxMerge(inData1 = flight_mrs, inData2 = weather_mrs, outFile = outFileOrigin,
                          type = 'inner', autoSort = TRUE, 
                          matchVars = c('Month', 'DayofMonth', 'OriginAirportID', 'CRSDepTime'),
                          varsToDrop2 = 'DestAirportID',
                          overwrite = TRUE)

# 2). Join flight records and weather data using the destination of the flight (DestAirportID).
destData_mrs <- rxMerge(inData1 = originData_mrs, inData2 = weather_mrs, outFile = outFileDest,
                        type = 'inner', autoSort = TRUE, 
                        matchVars = c('Month', 'DayofMonth', 'DestAirportID', 'CRSDepTime'),
                        varsToDrop2 = c('OriginAirportID'),
                        duplicateVarExt = c("Origin", "Destination"),
                        overwrite = TRUE)

#### Step 3: Prepare Training and Test Datasets.

# Randomly split 80% data as training set and the remaining 20% as test set.
rxSplit(inData = destData_mrs,
        outFilesBase = "modelData",
        outFileSuffixes = c("Train", "Test"),
        splitByFactor = "splitVar",
        overwrite = TRUE,
        transforms = list(splitVar = factor(sample(c("Train", "Test"), size = .rxNumRows, replace = TRUE, prob = c(.80, .20)),
                                            levels = c("Train", "Test"))),
        rngSeed = 17,
        consoleOutput = TRUE)
        


# Duplicate the test file for two models.
file.rename('modelData.splitVar.Test.xdf', 'modelData.splitVar.Test.logit.xdf')
file.copy('modelData.splitVar.Test.logit.xdf', 'modelData.splitVar.Test.tree.xdf')
train <- RxXdfData("modelData.splitVar.Train.xdf")
testLogit <- RxXdfData("modelData.splitVar.Test.logit.xdf")
testTree <- RxXdfData("modelData.splitVar.Test.tree.xdf")


#### Step 4A: Choose and apply a learning algorithm (Logistic Regression).

# Build the formula.
allvars <- names(finalData_mrs)
xvars <- allvars[allvars != 'ArrDel15']
form <- as.formula(paste("ArrDel15", "~", paste(xvars, collapse = "+")))
modelFormula <- formula(train, depVars = "ArrDel15", varsToDrop = c("RowNum", "splitVar"))

# Build a Logistic Regression model.
logitModel_mrs <- rxLogit(form, data = 'finalData.splitVar.Train.xdf')
summary(logitModel_mrs)


#### Step 5A: Predict over new data (Logistic Regression).

# Predict the probability on the test dataset.
predictLogit_mrs <- rxPredict(logitModel_mrs, data = 'finalData.splitVar.Test.logit.xdf',
                              type = 'response', overwrite = TRUE)

# Calculate Area Under the Curve (AUC).
rxAuc(rxRoc("ArrDel15", "ArrDel15_Pred", predictLogit_mrs)) # AUC = 0.67


#### Step 4B: Choose and apply a learning algorithm (Decision Tree).

# Build a decision tree model.
dTree1_mrs <- rxDTree(form, data = 'finalData.splitVar.Train.xdf')

# Find the Best Value of cp for Pruning rxDTree Object.
treeCp_mrs <- rxDTreeBestCp(dTree1_mrs)

# Prune a decision tree created by rxDTree and return the smaller tree.
dTree2_mrs <- prune.rxDTree(dTree1_mrs, cp = treeCp_mrs)


#### Step 5B: Predict over new data (Decision Tree).

# Predict the probability on the test dataset.
predictTree_mrs <- rxPredict(dTree2_mrs, data = 'finalData.splitVar.Test.tree.xdf',
                             overwrite = TRUE)

# Calculate Area Under the Curve (AUC).
rxAuc(rxRoc("ArrDel15", "ArrDel15_Pred", predictTree_mrs)) # AUC = 0.70


#### Close Up: Remove all .xdf files in the current directory.

rmFiles <- list.files(pattern = "\\.xdf")
file.remove(rmFiles)
