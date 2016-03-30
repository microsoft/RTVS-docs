# Microsoft R Open includes the Intel MKL for fast, parallel linear algebra 
# computations. This script runs performance benchmarks using different 
# numbers of threads

# The test uses the package "version.compare", available on GitHub.
# Install this package first, if it is not already installed.
# It uses RevoMultiBenchmark, and so requires that 
# Microsoft R Server be installed.

# Check whether Microsoft R Server (RRE 8.0) is installed.
suppressWarnings(
  if (!require("RevoScaleR")) {
    cat(
        "RevoScaleR package does not seem to exist. \n",
        "This means that the functions starting with 'rx' will not run. \n",
        "If you have Microsoft R Server installed, please switch the R engine.\n",
        "For example, in R Tools for Visual Studio: \n",
        "R Tools -> Options -> R Engine. \n",
        "If Microsoft R Server is not installed, you can download it from: \n",
        "https://www.microsoft.com/en-us/server-cloud/products/r-server/")

    quit()
    })

if (!require("version.compare")){
  (if (!require("devtools")) install.packages("devtools"))
  library("devtools") 
  devtools::install_github("andrie/version.compare")
}
library(version.compare)

cat("This script can take several minutes to run.\n")
cat("Make yourself comfortable.\n")

# Determine the local installation path.
r <- findRscript(
  version = as.character(getRversion())
)

# Determine how many threads to use, in sequence 1,2,4,8...
# up to maximum number of physical processors on the machine.
threadsToTest <- if(exists("setMKLthreads")){
  local({
    threads <- 2^(0:4)
    max <- match(RevoUtilsMath:::.Default.Revo.Threads, threads)
    threads[seq_len(max)]
  })
} else {
  1
}

# Run the benchmark tests.
# Set scale.factor to 1 for the full tests, lower than 1 for tests on 
# reduces data set sizes.
scale.factor <- 0.25
x <- RevoMultiBenchmark(r, threads = threadsToTest, scale.factor = scale.factor)

# Print a table of results.
print(x)

# Create a plot.
p <- plot(x, theme_size = 12)
print(p)
