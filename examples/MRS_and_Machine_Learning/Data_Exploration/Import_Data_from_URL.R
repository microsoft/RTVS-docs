# This script shows how to import data into R that is referenced by a URL.

# Install the RCurl package if it's not already installed.
(if (!require("RCurl", quietly = TRUE)) install.packages("RCurl"))

# Load packages.
library("RCurl", quietly = TRUE)

# A URL contains the raw data.
github <- "https://raw.githubusercontent.com/brohrer-ms/RTVS-docs/master/examples/MRS_and_Machine_Learning/Datasets/"
inputDataURL <- paste0(github, "Flight_Delays_Sample.csv")

# Download data from the URL.
inputData <- getURL(inputDataURL)

# Read downloaded data into a data frame.
df <- read.csv(text = inputData, na.strings = "NA", stringsAsFactors = FALSE)

# Review the first 6 rows of data.
head(df)
