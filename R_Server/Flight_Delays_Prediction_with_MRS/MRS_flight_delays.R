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


#### Step 0: Get Started.

# Initial some variables.
inputFileFlightURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/R_Server/Flight_Delays_Prediction_with_MRS/Flight_Delays_Sample.csv"
inputFileWeatherURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/R_Server/Flight_Delays_Prediction_with_MRS/Weather_Sample.csv"
inputFileFlight <- "Flight_Delays_Sample.csv"
inputFileWeather <- "Weather_Sample.csv"
outFileFlight <- 'flight.xdf'
outFileFlight2 <- 'flight2.xdf'
outFileWeather <- 'weather.xdf'
outFileWeather2 <- 'weather2.xdf'
outFileOrigin <- 'originData.xdf'
outFileDest <- 'DestData.xdf'
outFileFinal <- 'finalData.xdf'

# Turn off the progress reported in MRS.
rxOptions(reportProgress = 0)


#### Step 1: Import Data.

# Import the flight data.
flight_mrs <- rxImport(inData = inputFileFlightURL, outFile = outFileFlight,
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


#### Step 2: Pre-process Data.

# Remove columns that are possible target leakers from the flight data. 
varsToDrop <- c('DepDelay', 'DepDel15', 'ArrDelay', 'Cancelled', 'Year')

# Round down scheduled departure time to full hour.
xform <- function(dataList) {
  # Create a new continuous variable from an existing continuous variables:
  # round down CSRDepTime column to the nearest hour.
  dataList$CRSDepTime <- sapply(dataList$CRSDepTime,
                                FUN = function(x) {
                                  floor(x / 100)
                                })
  
  # Return the adapted variable list.
  return(dataList)
}
flight_mrs <- rxDataStep(inData = flight_mrs,
                         outFile = outFileFlight2,
                         varsToDrop = varsToDrop,
                         transformFunc = xform,
                         transformVars = 'CRSDepTime',
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


#### Step 3: Prepare Training and Test Datasets.

# Randomly split 80% data as training set and the remaining 20% as test set.
rxExec(rxSplit, inData = finalData_mrs,
       outFilesBase = "finalData",
       outFileSuffixes = c("Train", "Test"),
       splitByFactor = "splitVar",
       overwrite = TRUE,
       transforms = list(splitVar = factor(sample(c("Train", "Test"), size = .rxNumRows, replace = TRUE, prob = c(.80, .20)),
                                           levels = c("Train", "Test"))),
       rngSeed = 17,
       consoleOutput = TRUE)

# Duplicate the test file for two models.
file.rename('finalData.splitVar.Test.xdf', 'finalData.splitVar.Test.logit.xdf')
file.copy('finalData.splitVar.Test.logit.xdf', 'finalData.splitVar.Test.tree.xdf')


#### Step 4A: Choose and apply a learning algorithm (Logistic Regression).

# Build the formula.
allvars <- names(finalData_mrs)
xvars <- allvars[allvars != 'ArrDel15']
form <- as.formula(paste("ArrDel15", "~", paste(xvars, collapse = "+")))

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
