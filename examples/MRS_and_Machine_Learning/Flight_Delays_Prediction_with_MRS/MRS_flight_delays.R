## Flight Delay Prediction with Microsoft R Server

# In this example, we use historical on-time performance and 
# weather data to predict whether the arrival of a scheduled passenger 
# flight will be delayed by more than 15 minutes.

# We approach this problem as a classification problem, 
# predicting two classes -- whether the flight will be delayed, 
# or whether it 
# will be on time. Broadly speaking, in machine learning and 
# statistics, classification is the task of identifying 
# the class or category 
# to which a new observation belongs, on the basis of 
# a training set of data containing observations with known categories. 
# Classification is generally a supervised learning problem. 
# Since this is a binary classification task, there are only two classes.

# In this example, we train a model using a large number of examples 
# from historic flight data, along with an outcome measure that 
# indicates the appropriate category or class for each example. 
# The two classes are labeled 1 if a flight was delayed, and labeled 0 
# if the flight was on time.

# The following scripts include five basic steps of building 
# this example using Microsoft R Server.
# This execution might require several minutes.


### Step 0: Get Started

# Check if Microsoft R Server (RRE 8.0) is installed.
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

# Initial some variables.
github <- "https://raw.githubusercontent.com/brohrer-ms/RTVS-docs/master/examples/MRS_and_Machine_Learning/Datasets/"
inputFileFlightURL <- paste0(github, "Flight_Delays_Sample.csv")
inputFileWeatherURL <- paste0(github, "Weather_Sample.csv")

# Create a temporary directory to store the intermediate .xdf files.
td <- tempdir()
outFileFlight <- paste0(td, "/flight.xdf")
outFileWeather <- paste0(td, "/weather.xdf")
outFileOrigin <- paste0(td, "/originData.xdf")
outFileDest <- paste0(td, "/destData.xdf")
outFileFinal <- paste0(td, "/finalData.xdf")


### Step 1: Import Data

# Import the flight data.
flight_mrs <- rxImport(
  inData = inputFileFlightURL, outFile = outFileFlight,
  missingValueString = "M", stringsAsFactors = FALSE,
  # Remove columns that are possible target leakers from the flight data.
  varsToDrop = c("DepDelay", "DepDel15", "ArrDelay", "Cancelled", "Year"),
  # Define "Carrier" as categorical.
  colInfo = list(Carrier = list(type = "factor")),
  # Round down scheduled departure time to full hour.
  transforms = list(CRSDepTime = floor(CRSDepTime/100)),  
  overwrite = TRUE
)

# Review the first 6 rows of flight data.
head(flight_mrs)

# Summary the flight data.
rxSummary(~., data = flight_mrs, blocksPerRead = 2)

# Import the weather data.
xform <- function(dataList) {
  # Create a function to normalize some numerical features.
  featureNames <- c(
  "Visibility", 
  "DryBulbCelsius", 
  "DewPointCelsius", 
  "RelativeHumidity", 
  "WindSpeed", 
  "Altimeter"
  )
  dataList[featureNames] <- lapply(dataList[featureNames], scale)
  return(dataList)
}

weather_mrs <- rxImport(
  inData = inputFileWeatherURL, outFile = outFileWeather,
  missingValueString = "M", stringsAsFactors = FALSE,
  # Eliminate some features due to redundance.
  varsToDrop = c("Year", "Timezone", 
                 "DryBulbFarenheit", "DewPointFarenheit"),
  # Create a new column "DestAirportID" in weather data.
  transforms = list(DestAirportID = AirportID),
  # Apply the normalization function.
  transformFunc = xform,  
  transformVars = c(
    "Visibility", 
    "DryBulbCelsius", 
    "DewPointCelsius", 
    "RelativeHumidity", 
    "WindSpeed", 
    "Altimeter"
    ),
  overwrite = TRUE
)

# Review the variable information of weather data.
rxGetVarInfo(weather_mrs)


### Step 2: Pre-process Data

# Rename some column names in the weather data to prepare it for merging.
newVarInfo <- list(
  AdjustedMonth = list(newName = "Month"),
  AdjustedDay = list(newName = "DayofMonth"),
  AirportID = list(newName = "OriginAirportID"),
  AdjustedHour = list(newName = "CRSDepTime")
)
rxSetVarInfo(varInfo = newVarInfo, data = weather_mrs)

# Concatenate/Merge flight records and weather data.
# 1). Join flight records and weather data at origin of the flight 
#     (OriginAirportID).
originData_mrs <- rxMerge(
  inData1 = flight_mrs, inData2 = weather_mrs, outFile = outFileOrigin,
  type = "inner", autoSort = TRUE, 
  matchVars = c("Month", "DayofMonth", "OriginAirportID", "CRSDepTime"),
  varsToDrop2 = "DestAirportID",
  overwrite = TRUE
)

# 2). Join flight records and weather data using the destination of 
#     the flight (DestAirportID).
destData_mrs <- rxMerge(
  inData1 = originData_mrs, inData2 = weather_mrs, outFile = outFileDest,
  type = "inner", autoSort = TRUE, 
  matchVars = c("Month", "DayofMonth", "DestAirportID", "CRSDepTime"),
  varsToDrop2 = c("OriginAirportID"),
  duplicateVarExt = c("Origin", "Destination"),
  overwrite = TRUE
)

# Call "rxFactors" function to convert "OriginAirportID" and 
# "DestAirportID" as categorical.
rxFactors(inData = destData_mrs, outFile = outFileFinal, sortLevels = TRUE,
          factorInfo = c("OriginAirportID", "DestAirportID"),
          overwrite = TRUE)


### Step 3: Prepare Training and Test Datasets

# Randomly split 80% data as training set and the remaining 20% as test set.
rxSplit(inData = outFileFinal,
        outFilesBase = paste0(td, "/modelData"),
        outFileSuffixes = c("Train", "Test"),
        splitByFactor = "splitVar",
        overwrite = TRUE,
        transforms = list(
          splitVar = factor(sample(c("Train", "Test"),
                                   size = .rxNumRows,
                                   replace = TRUE,
                                   prob = c(.80, .20)),
                            levels = c("Train", "Test"))),
        rngSeed = 17,
        consoleOutput = TRUE)

# Point to the .xdf files for the training and test set.
train <- RxXdfData(paste0(td, "/modelData.splitVar.Train.xdf"))
test <- RxXdfData(paste0(td, "/modelData.splitVar.Test.xdf"))


### Step 4A: Choose and apply a learning algorithm (Logistic Regression)

# Build the formula.
modelFormula <- formula(train, depVars = "ArrDel15",
                        varsToDrop = c("RowNum", "splitVar"))

# Fit a Logistic Regression model.
logitModel_mrs <- rxLogit(modelFormula, data = train)

# Review the model results.
summary(logitModel_mrs)


### Step 5A: Predict over new data (Logistic Regression)

# Predict the probability on the test dataset.
rxPredict(logitModel_mrs, data = test,
          type = "response",
          predVarNames = "ArrDel15_Pred_Logit",
          overwrite = TRUE)

# Calculate Area Under the Curve (AUC).
paste0("AUC of Logistic Regression Model:",
      rxAuc(rxRoc("ArrDel15", "ArrDel15_Pred_Logit", test)))

# Plot the ROC curve.
rxRocCurve("ArrDel15", "ArrDel15_Pred_Logit", data = test,
           title = "ROC curve - Logistic regression")


### Step 4B: Choose and apply a learning algorithm (Decision Tree)

# Build a decision tree model.
dTree1_mrs <- rxDTree(modelFormula, data = test, reportProgress = 1)

# Find the Best Value of cp for Pruning rxDTree Object.
treeCp_mrs <- rxDTreeBestCp(dTree1_mrs)

# Prune a decision tree created by rxDTree and return the smaller tree.
dTree2_mrs <- prune.rxDTree(dTree1_mrs, cp = treeCp_mrs)


### Step 5B: Predict over new data (Decision Tree)

# Predict the probability on the test dataset.
rxPredict(dTree2_mrs, data = test,
          predVarNames = "ArrDel15_Pred_Tree",
          overwrite = TRUE)

# Calculate Area Under the Curve (AUC).
paste0("AUC of Decision Tree Model:",
       rxAuc(rxRoc(" ArrDel15 ", " ArrDel15_Pred_Tree ", test)))

# Plot the ROC curve.
rxRocCurve("ArrDel15",
           predVarNames = c("ArrDel15_Pred_Tree", "ArrDel15_Pred_Logit"),
           data = test,
           title = "ROC curve - Logistic regression")
