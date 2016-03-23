## Flight Delay Prediction with Open Source R

# This example demostrates a step-by-step comparison of solving 
# a Machine Learning use case using open
# source R (a.k.a. CRAN R) and Microsoft R Server. 
# The Microsoft R Server script is available in a GitHub
# repository: 
# https://github.com/Microsoft/RTVS-docs/tree/master/examples/Introduction_to_R_Server/Flight_Delays_Prediction_with_MRS.

# In this example, we use historical on-time performance and 
# weather data to predict whether the arrival 
# of a scheduled passenger flight will be delayed by more than 15 minutes.

# We approach this problem as a classification problem, 
# predicting two classes -- whether the flight will 
# be delayed, or whether it will be on time. 
# Broadly speaking, in machine learning and statistics, 
# classification is the task of identifying the class 
# or category to which a new observation belongs, on 
# the basis of a training set of data containing 
# observations with known categories. Classification is 
# generally a supervised learning problem. 
# Since this is a binary classification task, there are only two 
# classes.

# In this example, we train a model using a large number 
# of examples from historic flight data, along with 
# an outcome measure that indicates the appropriate category 
# or class for each example. The two classes 
# are labeled 1 if a flight was delayed, and labeled 0 
# if the flight was on time.

# The following scripts include five basic steps of building 
# this example using open source R.
# This execution may require serveral minutes.


### Step 0: Get Started

# Initialize some variables.
github <- "https://raw.githubusercontent.com/brohrer-ms/RTVS-docs/master/examples/MRS_and_Machine_Learning/Datasets/"
inputFileFlightURL <- paste0(github, "Flight_Delays_Sample.csv")
inputFileWeatherURL <- paste0(github, "Weather_Sample.csv")

# Import packages.
# Load RCurl package for importing files from a URL.
(if (!require("RCurl", quietly = TRUE)) install.packages("RCurl"))
library("RCurl", quietly = TRUE)
# Load rpart package for building the decision tree model.
(if (!require("rpart", quietly = TRUE)) install.packages("rpart"))
library("rpart", quietly = TRUE) 

# Download URLs of flight and weather data.
inputFileFlight <- getURL(inputFileFlightURL)
inputFileWeather <- getURL(inputFileWeatherURL)


### Step 1: Import Data

# Import the flight data.
flight_r <- read.csv(text = inputFileFlight,
                     na.strings = "NA",
                     stringsAsFactors = FALSE)

# Review the first 6 rows of flight data.
head(flight_r)

# Summary the flight data.
summary(flight_r)

# Import the weather dataset and eliminate some features due to redundance.
weather_r <- subset(read.csv(text = inputFileWeather,
                             na.strings = "NA",
                             stringsAsFactors = FALSE),
                    select = -c(Year, Timezone,
                                DryBulbFarenheit,
                                DewPointFarenheit))


### Step 2: Pre-process Data

# Remove some columns that are possible target leakers from the flight data.
# And round down scheduled departure time to full hour.
xform_r <- function(df) {
  # Remove columns that are possible target leakers.
  varsToDrop <- c('DepDelay', 'DepDel15', 'ArrDelay', 'Cancelled', 'Year')
  df <- df[, !(names(df) %in% varsToDrop)]
  # Round down scheduled departure time to full hour.
  df$CRSDepTime <- floor(df$CRSDepTime / 100)
  # Return the data frame.
  return(df)
}
flight_r <- xform_r(flight_r)

# Rename some column names in the weather data to prepare it for merging.
xform2_r <- function(df) {
  # Create a new column 'DestAirportID' in weather data.
  df$DestAirportID <- df$AirportID
  # Rename 'AdjustedMonth', 'AdjustedDay', 'AirportID', 'AdjustedHour'.
  names(df)[match(c('AdjustedMonth', 'AdjustedDay', 
                    'AirportID', 'AdjustedHour'),
                  names(df))] <- c('Month', 'DayofMonth', 
                                   'OriginAirportID', 'CRSDepTime')
  # Return the data frame.
  return(df)
}
weather_r <- xform2_r(weather_r)

# Concatenate/Merge flight records and weather data.
# 1). Join flight records and weather data at origin of the flight 
#     (OriginAirportID).
mergeFunc <- function(df1, df2) {
  # Remove the "DestAirportID" column from the weather data before the merge.
  df2 <- subset(df2, select = -DestAirportID)
  # Merge the two data frames.
  dfOut <- merge(df1, df2,
                 by = c('Month', 'DayofMonth', 
                        'OriginAirportID', 'CRSDepTime'))
  # Return the data frame.
  return(dfOut)
}
originData_r <- mergeFunc(flight_r, weather_r)

# 2). Join flight records and weather data using the destination of 
#     the flight (DestAirportID).
mergeFunc2 <- function(df1, df2) {
  # Remove the "OriginAirportID" column from the weather data 
  # before the merge.
  df2 <- subset(df2, select = -OriginAirportID)
  # Merge the two data frames.
  dfOut <- merge(df1, df2,
                 by = c('Month', 'DayofMonth', 
                        'DestAirportID', 'CRSDepTime'),
                 suffixes = c(".Origin", ".Destination"))
  # Return the data frame.
  return(dfOut)
}
destData_r <- mergeFunc2(originData_r, weather_r)

# Normalize some numerical features and convert some features 
# to be categorical.
# Features need to be normalized.
scaleVar <- c('Visibility.Origin', 
              'DryBulbCelsius.Origin', 
              'DewPointCelsius.Origin',
              'RelativeHumidity.Origin', 
              'WindSpeed.Origin', 
              'Altimeter.Origin',
              'Visibility.Destination', 
              'DryBulbCelsius.Destination', 
              'DewPointCelsius.Destination',
              'RelativeHumidity.Destination',   
              'WindSpeed.Destination', 
              'Altimeter.Destination')

# Features need to be converted to categorical.
cateVar <- c('OriginAirportID', 'Carrier')

xform3_r <- function(df) {
  # Normalization.
  df[, scaleVar] <- sapply(df[, scaleVar], FUN = function(x) {scale(x)})
  # Convert to categorical.
  df[, cateVar] <- sapply(df[, cateVar], FUN = function(x) {factor(x)                                                                  })
  # Return the data frame.
  return(df)
}
finalData_r <- xform3_r(destData_r)


### Step 3: Prepare Training and Test Datasets

# Randomly split 80% data as training set and the remaining 20% as test set.
set.seed(17)
sub <- sample(nrow(finalData_r), floor(nrow(finalData_r) * 0.8))
train <- finalData_r[sub,]
test <- finalData_r[ - sub,]


### Step 4A: Choose and apply a learning algorithm (Logistic Regression)

# Build the formula.
allvars <- names(finalData_r)
xvars <- allvars[allvars != 'ArrDel15']
form <- as.formula(paste("ArrDel15", "~", paste(xvars, collapse = "+")))

# Build a Logistic Regression model.
logitModel_r <- glm(form, data = train, family = "binomial")
summary(logitModel_r)


### Step 5A: Predict over new data (Logistic Regression)

# Predict the probability on the test dataset.
predictLogit_r <- predict(logitModel_r, newdata = test, type = 'response')
testLogit <- cbind(test, data.frame(ArrDel15_Pred = predictLogit_r))

# Calculate Area Under the Curve (AUC).
auc <- function(outcome, prob) {
  N <- as.numeric(length(prob))  # number of the records
  N_pos <- as.numeric(sum(outcome))  
  df <- data.frame(out = outcome, prob = prob)
  df <- df[order( - df$prob),]
  df$above <- (1:N) - cumsum(df$out)
  return(1 - sum(df$above * df$out) / (N_pos * (N - N_pos)))
}

paste0("AUC of Logistic Regression Model: ",
       auc(testLogit$ArrDel15, testLogit$ArrDel15_Pred))


### Step 4B: Choose and apply a learning algorithm (Decision Tree)

# Build a decision tree model.
dTree1_r <- rpart(form, data = train, method = 'class',
                  control = rpart.control(minsplit = 20,
                                          minbucket = 1,
                                          cp = 0,
                                          maxcompete = 0,
                                          maxSurrogate = 0,
                                          xval = 2,
                                          maxDepth = 10))

# Find the Best Value of cp for Pruning rxDTree Object.
treeCp_r <- dTree1_r$cptable[which.min(dTree1_r$cptable[, "xerror"]), "CP"]

# Prune a decision tree created by rxDTree and return the smaller tree.
dTree2_r <- prune(dTree1_r, cp = treeCp_r)


### Step 5B: Predict over new data (Decision Tree)

# Predict the probability on the test dataset.
predictTree_r <- predict(dTree2_r, newdata = test, type = 'prob')
testDT <- cbind(test, data.frame(ArrDel15_Pred = predictTree_r[, 2]))

# Calculate Area Under the Curve (AUC).
paste0("AUC of Decision Tree Model: ",
       auc(testDT$ArrDel15, testDT$ArrDel15_Pred))
