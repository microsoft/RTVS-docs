# Check the "RevoScaleR" package is loaded in the current RTVS enivronment.
tryCatch(
  {
    library("RevoScaleR")  # Load RevoScaleR package from Microsoft R Server.
    message("RevoScaleR package is succesfully loaded. Please continue with the further steps.")
  },
  error=function(e) {
    message("RevoScaleR package does not seem to exist...")
    message("Here's the original error message:")
    message(paste(e, "\n"))
    message("If you have Mircrosoft R Server installed, please switch the R engine in R Tools for Visual Studio: R Tools -> Options -> R Engine.")
    message("If Microsoft R Server is not installed, please download it from here: https://www.microsoft.com/en-us/server-cloud/products/r-server/.")
    return(NA)
  }
)    

# An URL contains the raw data.
inputDataURL <- "<an URL contains the raw data>"
#inputDataURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/R_Server/Flight_Delays_Prediction_with_MRS/Flight_Delays_Sample.csv"

# Read a downloaded .csv file into a RxXdfData object.
outFile <- 'data.xdf'
df_xdf <- rxImport(inData = inputDataURL, outFile = outFile,
                   missingValueString = "M", stringsAsFactors = FALSE)

# Review the first 6 rows of data.
head(df_xdf)
