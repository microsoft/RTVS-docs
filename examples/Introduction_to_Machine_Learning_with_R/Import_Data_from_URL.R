# Import libraries.
(if (!require("RCurl")) install.packages("RCurl"))
(if (!require("foreign")) install.packages("foreign"))
library(RCurl)
library(foreign)

# An URL contains the raw data.
inputDataURL <- "<an URL contains the raw data>"
#inputDataURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/R/Flight_Delays_Prediction_with_R/Flight_Delays_Sample.csv"

# Download data from the URL.
inputData <- getURL(inputFileFlightURL)

# Read downloaded data into a data frame.
df <- read.csv(text = inputData, na.strings = "NA", stringsAsFactors = FALSE)

# Review the first 6 rows of data.
head(df)
