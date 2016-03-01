# An URL contains the raw data.
inputDataURL <- "<an URL contains the raw data>"
#inputDataURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/R_Server/Flight_Delays_Prediction_with_MRS/Flight_Delays_Sample.csv"

# Read downloaded .csv file into a RxXdfData object.
outFile <- 'data.xdf'
df_xdf <- rxImport(inData = inputDataURL, outFile = outFile,
                   missingValueString = "M", stringsAsFactors = FALSE)

# Review the first 6 rows of data.
head(df_xdf)
