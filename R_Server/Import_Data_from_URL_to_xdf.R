# Import libraries.
(if (!require("RCurl")) install.packages("RCurl"))
(if (!require("foreign")) install.packages("foreign"))
library(RCurl)
library(foreign)

# An URL contains the raw data.
inputDataURL <- "<an URL contains the raw data>"
#inputDataURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/R_Server/Flight_Delays_Prediction_with_MRS/Flight_Delays_Sample.csv"

# Download data from the URL.
inputData <- "<a file name>"    # inputData <- "Flight_Delays_Sample.csv"
download.file(inputDataURL, destfile = inputData, method = "libcurl")

# Read downloaded .csv file into a RxXdfData object.
outFile <- 'data.xdf'
df_xdf <- rxImport(inData = inputData, outFile = outFile,
                   missingValueString = "M", stringsAsFactors = FALSE)

# Review the first 6 rows of data.
head(df_xdf)