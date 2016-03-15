# This brief example shows how to use Microsoft R Server 
# to download data from a URL.

# Check whether the "RevoScaleR" package is loaded in the current environment.
if (!require("RevoScaleR")) {
    cat("RevoScaleR package does not seem to exist. 
        \nThis means that the functions starting with 'rx' will not run. 
        \nIf you have Microsoft R Server installed, 
        \nplease switch the R engine.
        \nFor example, in R Tools for Visual Studio: 
        \nR Tools -> Options -> R Engine. 
        \nIf Microsoft R Server is not installed, you can download it from: 
        \nhttps://www.microsoft.com/en-us/server-cloud/products/r-server/
        \n")
  
    quit()
} 

# A URL contains the raw data.
github <- "https://raw.githubusercontent.com/brohrer-ms/RTVS-docs/master/examples/MRS_and_Machine_Learning/Datasets/"
inputDataURL <- paste0(github, "Flight_Delays_Sample.csv")

# Create a temporary directory to store the intermediate .xdf files.
td <- tempdir()

# Read a downloaded .csv file into a RxXdfData object.
outFile <- paste0(td, "/data.xdf")
df_xdf <- rxImport(inData = inputDataURL, outFile = outFile,
                   missingValueString = "M", stringsAsFactors = FALSE)

# Review the first 6 rows of data.
head(df_xdf)