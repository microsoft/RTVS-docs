# This brief example shows how to use Microsoft R Server 
# to download data from a URL.

# Check whether the "RevoScaleR" package is loaded in the current environment.
if (require("RevoScaleR")) {
    library("RevoScaleR") # Load RevoScaleR package from Microsoft R Server.
    message("RevoScaleR package is succesfully loaded.")
} else {
    message("Can't find RevoScaleR package...")
    message("If you have Microsoft R Server installed,")
    message("please switch the R engine")
    message("in R Tools for Visual Studio: R Tools -> Options -> R Engine.")
    message("If Microsoft R Server is not installed,")
    message("please download it from here:")
    message("https://www.microsoft.com/en-us/server-cloud/products/r-server/.")
}

# A URL contains the raw data.
inputDataURL <- "https://raw.githubusercontent.com/Microsoft/RTVS-docs/master/examples/Datasets/Flight_Delays_Sample.csv"

# Create a temporary folder to store the .xdf files.
(if (!exists("tmp")) dir.create("tmp", showWarnings = FALSE))

# Read a downloaded .csv file into a RxXdfData object.
outFile <- 'tmp/data.xdf'
df_xdf <- rxImport(inData = inputDataURL, outFile = outFile,
                   missingValueString = "M", stringsAsFactors = FALSE)

# Review the first 6 rows of data.
head(df_xdf)
