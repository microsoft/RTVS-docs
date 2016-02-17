# Note: download airOT201201.csv from http://packages.revolutionanalytics.com/datasets/AirOnTimeCSV2012/
csvFile <- "C:/tmp/air-csv/airOT201201.csv"
df <- read.csv(csvFile, colClasses = c("DAY_OF_WEEK" = "factor")) # optional: use nrows parameter to limit the number of rows read

# Check the number of observations
nrow(df)
# 486,133

# Print the variable names
names(df)

# Fit a logistic regression model
system.time(model1 <- glm(ARR_DEL15 ~ ORIGIN + DAY_OF_WEEK + DEP_TIME, data = df, family = binomial))
# elapsed time: 477.16 seconds

# Print information about the model
summary(model1)

# Note: download AirOnTime2012.xdf from http://packages.revolutionanalytics.com/datasets/
xdfFile <- "C:/tmp/AirOnTime2012.xdf"
xdf <- RxXdfData(xdfFile)

# Check the number of observations
rxGetInfo(xdf) # can also use nrow( xdf )
# Number of observations: 6,096,762 

# Print the variable names
rxGetVarInfo(xdf) # can also use names( xdf )

# Fit a logistic regression model using rxLogit
system.time(model2 <- rxLogit(ArrDel15 ~ Origin + DayOfWeek + DepTime, data = xdf))
# elapsed time: 6.7 seconds

# Print information about the model
summary(model2)

# Fit a logistic regression model using rxGlm
system.time(model3 <- rxGlm(ArrDel15 ~ Origin + DayOfWeek + DepTime, data = xdf, family = binomial))
# elapsed time: 9.4 seconds

# Print information about the model
summary(model3)
