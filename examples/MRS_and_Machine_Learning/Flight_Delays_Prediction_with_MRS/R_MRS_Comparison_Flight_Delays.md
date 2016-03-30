# Microsoft R Server vs. Open Source R Comparison: Flight Delay Prediction

This example is aiming to compare the performance and model accuracies 
between Microsoft R Server (MRS) and Open Source R (obtained from CRAN) 
by using a previous example 
([Flight Delay Prediction with Microsoft R Server]) that we built.

In the previous example, we use historical on-time performance and 
weather data to predict whether the arrival of a scheduled passenger 
flight will be delayed by more than 15 minutes.

The comparison is worked on a [Microsoft Data Science Virtual Machine] 
and here are some System Configuration Information:
- Operating System: Windows
- System Type: 64-bit
- Cores: 4
- Installed Memory (RAM): 28.0 GB
- Microsoft R Server Version: 8.0.0
- R Version: 3.2.2

In this example, we build a step-by-step comparison on the five steps 
in _Flight Delay Prediction with Microsoft R Server_ example:
- [Step 1: Import Data](#anchor-1)
- [Step 2: Pre-process Data](#anchor-2)
- [Step 3: Prepare Training and Test Datasets](#anchor-3)
- [Step 4A: Choose and apply a learning algorithm (Logistic Regression)](#anchor-4A)
- [Step 4B: Choose and apply a learning algorithm (Decision Tree)](#anchor-4B)
- [Step 5A: Predict over new data (Logistic Regression)](#anchor-5A)
- [Step 5B: Predict over new data (Decision Tree)](#anchor-5B)

Also, we compare the model accuracies for both 
Logistic Regression and Decision Tree models by using the 
`Area Under the Curve (AUC)` as the measure.
- [Model Accuracies Comparison](#anchor-6)

Data and R Scripts we will use in this example:
- **Flight Delays Data.csv** (unzip the **Flight Delays Data.zip** file)
- **Weather Data.csv**
- **MRS_flight_delays.R**
- **R_flight_delays.R**

Objective conclusions will be made purely based on 
the performance and model accuracies comparison as below.
- [Conclusions](#anchor-7)


------------------------------------------

## <a name="anchor-1"></a> Step 1: Import Data

Sub-step Names | Execution Time in MRS (in seconds) | Execution Time in R (in seconds)
------------- | ------------- | -------------
Import Flight Data (2,719,418*14) | 10.86 | 15.60
Import the weather dataset and eliminate some features (404,914*10) | 2.33 | 1.79

```
### MRS:
# Import the flight data.
system.time(flight_mrs <- rxImport(inData = inputFileFlight, outFile = outFileFlight,
                                   missingValueString = "M", stringsAsFactors = TRUE)
            )  # elapsed: 10.86 seconds

# Import the weather dataset and eliminate some features due to redundance.
system.time(weather_mrs <- rxImport(inData = inputFileWeather, outFile = outFileWeather,
                                    missingValueString = "M", stringsAsFactors = TRUE,
                                    varsToDrop = c('Year', 'Timezone', 'DryBulbFarenheit', 'DewPointFarenheit'),
                                    overwrite=TRUE)
            )  # elapsed: 2.33 seconds
```

```
### Open Source R:
# Import the flight data.
system.time(flight_r <- read.csv(file = inputFileFlight, na.strings = "NA",
                                 stringsAsFactors = TRUE)
            )  # elapsed: 15.60 seconds

# Import the weather dataset and eliminate some features due to redundance.
system.time(weather_r <- subset(read.csv(file = inputFileWeather, na.strings = "NA",
                                         stringsAsFactors = TRUE),
                                select = -c(Year, Timezone, DryBulbFarenheit, DewPointFarenheit)
                                )
            )  # elapsed: 1.79 seconds
```


## <a name="anchor-2"></a> Step 2: Pre-process Data

Sub-step Names | Execution Time in MRS (in seconds) | Execution Time in R (in seconds)
------------- | ------------- | -------------
Remove target leakers from flight data and round down scheduled departure time to full hour | 4.75 | 0.03
Rename some column names from weather data to prepare it for merging | 0.34 | <0.01
Join flight records and weather data at OriginAirportID | 28.44 | 43.92
Join flight records and weather data at DestAirportID | 36.25 | 37.53
Normalize some numerical features and convert some features to be categorical | 10.39 | 39.98

```
### MRS:
# Remove columns that are possible target leakers from the flight data.
varsToDrop <- c('DepDelay', 'DepDel15', 'ArrDelay', 'Cancelled', 'Year')

# Round down scheduled departure time to full hour.
xform <- function(dataList) {
  # Create a new continuous variable from an existing continuous variables:
  # round down CSRDepTime column to the nearest hour.
  dataList$CRSDepTime <- sapply(dataList$CRSDepTime,
                                FUN = function(x) {floor(x/100)})

  # Return the adapted variable list.
  return(dataList)
}
system.time(flight_mrs <- rxDataStep(inData = flight_mrs,
                                   outFile = outFileFlight2,
                                   varsToDrop = varsToDrop,
                                   transformFunc = xform,
                                   transformVars = 'CRSDepTime',
                                   overwrite=TRUE
                                   )
            )  # elapsed: 4.75 seconds

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
system.time(weather_mrs <- rxDataStep(inData = weather_mrs,
                                      outFile = outFileWeather2,
                                      transformFunc = xform2,
                                      transformVars = c('AdjustedMonth', 'AdjustedDay', 'AirportID', 'AdjustedHour'),
                                      overwrite=TRUE
                                      )
            )  # elapsed: 0.34 seconds

# Concatenate/Merge flight records and weather data.
# 1). Join flight records and weather data at origin of the flight (OriginAirportID).
system.time(originData_mrs <- rxMerge(inData1 = flight_mrs, inData2 = weather_mrs, outFile = outFileOrigin,
                                      type = 'inner', autoSort = TRUE, decreasing = FALSE,
                                      matchVars = c('Month', 'DayofMonth', 'OriginAirportID', 'CRSDepTime'),
                                      varsToDrop2 = 'DestAirportID',
                                      overwrite=TRUE
                                      )
            )  # elapsed: 28.44 seconds

# 2). Join flight records and weather data using the destination of the flight (DestAirportID).
system.time(destData_mrs <- rxMerge(inData1 = originData_mrs, inData2 = weather_mrs, outFile = outFileDest,
                                    type = 'inner', autoSort = TRUE, decreasing = FALSE,
                                    matchVars = c('Month', 'DayofMonth', 'DestAirportID', 'CRSDepTime'),
                                    varsToDrop2 = c('OriginAirportID'),
                                    duplicateVarExt = c("Origin", "Destination"),
                                    overwrite=TRUE
                                    )
            )  # elapsed: 36.25 seconds

# Normalize some numerical features and convert some features to be categorical.
system.time(finalData_mrs <- rxDataStep(inData = destData_mrs, outFile = outFileFinal,
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

                                                          # Convert 'OriginAirportID', 'DestAirportID' to categorical features
                                                          OriginAirportID = factor(OriginAirportID),
                                                          DestAirportID = factor(DestAirportID)
                                                          ),
                                        overwrite=TRUE
                                        )
            )  # elapsed: 10.39 seconds
```

```
### Open Source R:
# Remove some columns that are possible target leakers from the flight data.
# And round down scheduled departure time to full hour.
xform_r <- function(df) {
  # Remove columns that are possible target leakers.
  varsToDrop <- c('DepDelay', 'DepDel15', 'ArrDelay', 'Cancelled', 'Year')
  df <- df[, !(names(df) %in% varsToDrop)]

  # Round down scheduled departure time to full hour.
  df$CRSDepTime <- floor(df$CRSDepTime/100)

  # Return the data frame.
  return(df)
}
system.time(flight_r <- xform_r(flight_r))  # elapsed: 0.03 seconds

# Rename some column names in the weather data to prepare it for merging.
xform2_r <- function(df) {
  # Create a new column 'DestAirportID' in weather data.
  df$DestAirportID <- df$AirportID

  # Rename 'AdjustedMonth', 'AdjustedDay', 'AirportID', 'AdjustedHour'.
  names(df)[match(c('AdjustedMonth', 'AdjustedDay', 'AirportID', 'AdjustedHour'),
                  names(df))] <- c('Month', 'DayofMonth', 'OriginAirportID', 'CRSDepTime')

  # Return the data frame.
  return(df)
}
system.time(weather_r <- xform2_r(weather_r))  # elapsed: <0.01 seconds

# Concatenate/Merge flight records and weather data.
# 1). Join flight records and weather data at origin of the flight (OriginAirportID).
mergeFunc <- function(df1, df2) {
  # Remove the "DestAirportID" column from the weather data before the merge.
  df2 <- subset(df2, select = -DestAirportID)

  # Merge the two data frames.
  dfOut <- merge(df1, df2,
                 by = c('Month', 'DayofMonth', 'OriginAirportID', 'CRSDepTime'))

  # Return the data frame.
  return(dfOut)
}
system.time(originData_r <- mergeFunc(flight_r, weather_r)) # elapsed: 43.92 seconds

# 2). Join flight records and weather data using the destination of the flight (DestAirportID).
mergeFunc2 <- function(df1, df2) {
  # Remove the "OriginAirportID" column from the weather data before the merge.
  df2 <- subset(df2, select = -OriginAirportID)

  # Merge the two data frames.
  dfOut <- merge(df1, df2,
                 by = c('Month', 'DayofMonth', 'DestAirportID', 'CRSDepTime'),
                 suffixes = c(".Origin", ".Destination"))

  # Return the data frame.
  return(dfOut)
}
system.time(destData_r <- mergeFunc2(originData_r, weather_r)) # elapsed: 37.53 seconds

# Normalize some numerical features and convert some features to be categorical.
# Features need to be normalized.
scaleVar <- c('Visibility.Origin', 'DryBulbCelsius.Origin', 'DewPointCelsius.Origin',
              'RelativeHumidity.Origin', 'WindSpeed.Origin', 'Altimeter.Origin',
              'Visibility.Destination', 'DryBulbCelsius.Destination', 'DewPointCelsius.Destination',
              'RelativeHumidity.Destination', 'WindSpeed.Destination', 'Altimeter.Destination')

# Features need to be converted to categorical.
cateVar <- c('OriginAirportID', 'DestAirportID')

xform3_r <- function(df) {
  # Normalization.
  df[, scaleVar] <- sapply(df[, scaleVar], FUN = function(x) {scale(x)})

  # Convert to categorical.
  df[, cateVar] <- sapply(df[, cateVar], FUN = function(x) {factor(x)})

  # Return the data frame.
  return(df)
}
system.time(finalData_r <- xform3_r(destData_r))  # elapsed: 39.98 seconds
```


## <a name="anchor-3"></a> Step 3: Prepare Training and Test Datasets

Sub-step Names | Execution Time in MRS (in seconds) | Execution Time in R (in seconds)
------------- | ------------- | -------------
Randomly select 80/20 as training/test | 9.19 | 0.04

```
### MRS:
# Randomly split 80% data as training set and the remaining 20% as test set.
system.time(rxExec(rxSplit, inData = finalData_mrs,
                   outFilesBase="finalData",
                   outFileSuffixes=c("Train", "Test"),
                   splitByFactor="splitVar",
                   overwrite=TRUE,
                   transforms=list(splitVar = factor(sample(c("Train", "Test"), size=.rxNumRows, replace=TRUE, prob=c(.80, .20)),
                                   levels= c("Train", "Test"))),
                   rngSeed=17,
                   consoleOutput=TRUE
                   )
            )  # elapsed: 9.19 seconds
```

```
### Open Source R:
# Randomly split 80% data as training set and the remaining 20% as test set.
set.seed(17)
system.time(sub <- sample(nrow(finalData_r), floor(nrow(finalData_r) * 0.8)))  # elapsed: 0.04 seconds
```


## <a name="anchor-4A"></a> Step 4A: Choose and apply a learning algorithm (Logistic Regression)

Sub-step Names | Execution Time in MRS (in seconds) | Execution Time in R (in seconds)
------------- | ------------- | -------------
Build a Logistic Regression model | 5.50 | 229.32

```
### MRS:
# Build a Logistic Regression model.
system.time(logitModel_mrs <- rxLogit(form, data = 'finalData.splitVar.Train.xdf'))  # elapsed: 5.50 seconds
```

```
### Open Source R:
# Build a Logistic Regression model.
system.time(logitModel_r <- glm(form, data = train, family = "binomial"))  # elapsed: 229.32 seconds
```


## <a name="anchor-5A"></a> Step 5A: Predict over new data (Logistic Regression)

Sub-step Names | Execution Time in MRS (in seconds) | Execution Time in R (in seconds)
------------- | ------------- | -------------
Predict the probability on the test dataset | 0.56 | 1.72

```
### MRS:
# Predict the probability on the test dataset.
system.time(predictLogit_mrs <- rxPredict(logitModel_mrs, data = 'finalData.splitVar.Test.logit.xdf',
                                          type = 'response', overwrite = TRUE)
            ) # elapsed: 0.56 seconds
```

```
### Open Source R:
# Predict the probability on the test dataset.
system.time(predictLogit_r <- predict(logitModel_r, newdata = test, type = 'response'))  # elapsed: 1.72 seconds
```


## <a name="anchor-4B"></a> Step 4B: Choose and apply a learning algorithm (Decision Tree)

Sub-step Names | Execution Time in MRS (in seconds) | Execution Time in R (in seconds)
------------- | ------------- | -------------
Build a Decision Tree model | 151.69 | 360.10
Prune a Decision Tree to return the smaller tree | 0.03 | 4.25

```
### MRS:
# Build a decision tree model.
system.time(dTree1_mrs <- rxDTree(form, data = 'finalData.splitVar.Train.xdf'))  # elapsed: 151.69 seconds

# Prune a decision tree created by rxDTree and return the smaller tree.
system.time(dTree2_mrs <- prune.rxDTree(dTree1_mrs, cp = treeCp_mrs))  # elapsed: 0.03 seconds
```

```
### Open Source R:
# Build a decision tree model.
(if(!require("rpart")) install.packages("rpart"))
library(rpart)
system.time(dTree1_r <- rpart(form, data = train, method = 'class',
                              control=rpart.control(minsplit = 20, minbucket = 1, cp = 0,
                                                    maxcompete = 0, maxSurrogate = 0,
                                                    xval = 2, maxDepth = 10)))  # elapsed: 360.10 seconds

# Prune a decision tree created by rxDTree and return the smaller tree.
system.time(dTree2_r <- prune(dTree1_r, cp = treeCp_r))   # elapsed: 4.25 seconds
```


## <a name="anchor-5B"></a> Step 5B: Predict over new data (Decision Tree)

Sub-step Names | Execution Time in MRS (in seconds) | Execution Time in R (in seconds)
------------- | ------------- | -------------
Predict the probability on the test dataset | 1.16 | 13.53

```
### MRS:
# Predict the probability on the test dataset.
system.time(predictTree_mrs <- rxPredict(dTree2_mrs, data = 'finalData.splitVar.Test.tree.xdf',
                                         overwrite = TRUE)
            )  # elapsed: 1.16 seconds
```

```
### Open Source R:
# Predict the probability on the test dataset.
system.time(predictTree_r <- predict(dTree2_r, newdata = test, type = 'prob'))  # elapsed: 13.53 seconds
```


## <a name="anchor-6"></a> Model Accuracies Comparison

The Logistic Regression models have a `AUC` of **0.70** in both MRS and open source R.

```
### MRS:
# Calculate Area Under the Curve (AUC).
rxAuc(rxRoc("ArrDel15", "ArrDel15_Pred", predictLogit_mrs))  # AUC = 0.70
```

```
### Open Source R:
# Calculate Area Under the Curve (AUC).
auc <- function(outcome, prob){
  N <- length(prob)
  N_pos <- sum(outcome)
  df <- data.frame(out = outcome, prob = prob)
  df <- df[order(-df$prob),]
  df$above <- (1:N) - cumsum(df$out)
  return( 1- sum( df$above * df$out ) / (N_pos * (N-N_pos) ) )
}
auc(testLogit$ArrDel15, testLogit$ArrDel15_Pred)  # AUC = 0.70
```

For the Decision Tree model, we use the open source `rpart` function to compare with the MRS `rxDTree` function. Both functions can be used to fit classification trees. But some parameters, such as `minsplit`, `minbucket`, `maxcompete`, `maxSurrogate`, `xval`, `maxDepth` and etc., have different default values in both functions.

- `minSplit`: the minimum number of observations that must exist in a node before a split is attempted.
- `minBucket`: the minimum number of observations in a terminal node (or leaf).
- `maxCompete`: the maximum number of competitor splits retained in the output. These are useful model diagnostics, as they allow you to compare splits in the output with the alternatives.
- `maxSurrogate`: the maximum number of surrogate splits retained in the output.
- `xVal`: number of cross-validations performed in the model fit.
- `maxDepth`: the maximum depth of any tree node.

In order to have a fair comparison, we adjust the default values of those parameters in `rpart` function to be equal to the default values in `rxDTree` function. After pruning the trees to find the best value of `cp` (numeric scalar specifying the complexity parameter), `rxDTree` finds the best `cp` value as **2.156921e-05** and open source `rpart` finds the best `cp` value as **1.063143e-05**.

By using those two `cp` values to prune the trees, the Decision Tree models have a `AUC` of **0.73** in MRS and a `AUC` of **0.74** in open source R. We also want to understand whether the open source R will return a same `AUC` after giving the same best `cp` value of **2.156921e-05** as we obtained in MRS. A same `AUC` of **0.73** returns in this attempt. Therefore, the underlying algorithm for building a decision tree is the same in both MRS and open source R library `rpart`.


## <a name="anchor-7"></a> Conclusions

Since the model accuracies are the same in both MRS and open source R, we want to compare the overall and step-by-step execution time in MRS and R. Based on the below **Total Execution Time Comparison**, we can see MRS takes 261.49 seconds, which is only 35% of the total execution time in open source R.

![][total]

The **Total Execution Time Breakdown** indicates the _Join Data_, _Edit Metadata_ and _Train Model_ steps take the major percentage of the total execution time in open source R.

![][total_breakdown]

We are also interested in seeing the **Step-by-Step Execution Time Comparison**.

![][step]

**Based on the above overall and step-by-step comparisons, we reach the below conclusions:**

1. Overall, Microsoft R Server uses much less execution time (**261.49 seconds**) comparing to open source R (747.82 seconds). This leads to a **65%** improvement in terms of the performance.
2. Microsoft R Server has a better performance importing large-scale datasets comparing to open source R. The large-scale datasets can be considered as over millions-level records. For the thousands-level dataset, Microsoft R Server seems to have the similar performance with the open source R.
3. Microsoft R Server works very well in the data pre-processing stage, especially when joining two relatively large datasets and editing the metadata.
4. Microsoft R Server uses a bit more time when randomly splitting data into training and test datasets. But since it's writing datasets into external `.xdf` files at the same time and open source R doesn't have this intermediate step, the little time difference is acceptable.
5. Microsoft R Server really makes itself stand out when learning algorithms (training models) and predicting over the new data (scoring models). For both Logistic Regression and Decision Tree models, Microsoft R Server saves a significant amount of execution time in these two steps comparing to open source R. Also, learning algorithms and predicting outcomes overall cost the largest amount of time, so the significant time savings truly improve the total performance.



<!-- Links -->
[Flight Delay Prediction with Microsoft R Server]: https://github.com/mezmicrosoft/Microsoft_R_Server/tree/master/Flight_Delay_Prediction
[Microsoft Data Science Virtual Machine]: https://azure.microsoft.com/en-us/marketplace/partners/microsoft-ads/standard-data-science-vm/


<!-- Images -->
[total]:https://raw.githubusercontent.com/mezmicrosoft/Microsoft_R_Server/master/MRS%20and%20R%20Comparison/total.png
[total_breakdown]:https://raw.githubusercontent.com/mezmicrosoft/Microsoft_R_Server/master/MRS%20and%20R%20Comparison/total_breakdown.png
[step]:https://raw.githubusercontent.com/mezmicrosoft/Microsoft_R_Server/master/MRS%20and%20R%20Comparison/step.png
