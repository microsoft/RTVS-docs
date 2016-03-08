# Import packages.
(if (!require("RCurl")) install.packages("RCurl"))
library("RCurl")
(if (!require("foreign")) install.packages("foreign"))
library("foreign")

# A URL contains the raw data.
inputDataURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/Datasets/Flight_Delays_Sample.csv"

# Download data from the URL.
inputData <- getURL(inputDataURL)

# Read downloaded data into a data frame.
df <- read.csv(text = inputData, na.strings = "NA", stringsAsFactors = FALSE)

# Review the first 6 rows of data.
head(df)
