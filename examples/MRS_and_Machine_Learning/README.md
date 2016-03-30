## MRS and Machine Learning
This collection of examples shows how to use R and MRS to create 
machine learning models and how to take advantage of the
functionality of Mircosoft R Server. In order to run scripts with 
`MRS` in the title, it will be necessary to first [install MRS]
(https://www.microsoft.com/en-us/server-cloud/products/r-server/). 

### Flight Delays Prediction with R 

* **R Flight Delays with MRS Comparison.R**
This sample shows how to predict flight delays using R, machine learning
and historical on-time performance and weather data . 
When paired with `MRS Flight Delays with R Comparison.R`, it provides a step-by-step comparison 
of the functionality of open source R (a.k.a. CRAN R) and Microsoft R Server. 

### Flight Delays Prediction with MRS

* **MRS Flight Delays with R comparison.R**
This sample shows how to predict flight delays using R, machine learning
and historical on-time performance and weather data . 
When paired with `MRS Flight Delays with MRS Comparison.R`, it provides a step-by-step comparison 
of the functionality of open source R (a.k.a. CRAN R) and Microsoft R Server. 

* **MRS Flight Delays.R**
This sample shows how to build the same model as `MRS Flight Delays with R comparison.R`, but 
uses MRS best practices and syntax, which can differ substantially from those of R.
  
### Bike Rental Estimation with MRS

* **MRS Bike Rental Estimation.R** 
  This sample creates a demand prediction model for bike rentals based on 
a historical data set, using Microsoft R Server. 


### R MRO MRS Comparison
These samples show where the commands, syntax, constructs and performance of 
R, Microsoft R Open and Microsoft R Server are similar, and where they differ.
They include

* **R MRO MRS Comparison Part 1a Functions glm rxGlm.R**
* **R MRO MRS Comparison Part 1b Functions kmeans rxKmeans.R**
* **R MRO MRS Comparison Part 2 Capacity.R**
* **R MRO MRS Comparison Part 3a Speed for Matrix Calculations.R**
* **R MRO MRS Comparison Part 3b Speed for kmeans.R**
* **R MRO MRS Comparison Part 3c Speed for kmneans rxKmeans.R**


### Comparisons

* **MRO MKL benchmarks.R** 
Microsoft R Open includes the Intel Math Kernel Library (MKL) 
for fast, parallel linear algebra 
computations. This example runs a number of compute-intensive benchmarks to show the
performance gains that are possible through the use of MKL.

* **rxGlm benchmark.R**
This example demonstrates the differences between CRAN R and R server.
Specifically, it shows how the difference in performance between rxGlm() and
glm(). The R server function rxGlm() fits a generalized linear model on data
that is potentially much larger than available RAM.
NOTE: The CRAN portion of this comparison requires about 7GB of RAM.
If your machine has less, this script will crash.

### Machine Learning  
  
* **Gradient Boosting Machine.R**
This sample shows how to create, train and evaluate
a gradient boosting machine model in R.
This example uses a Gradient Boosting machine to create a model that predicts
[housing prices in the suburbs of
Boston](https://cran.r-project.org/web/packages/MASS/MASS.pdf) based on features
such as per-capita crime statistics, number of rooms per dwelling and the
property tax rate. Note that it takes quite some time to run this model, so
don't expect immediate results. If you find that it takes too long, there is a
commented out block of code that you can substitute that has a smaller parameter
tuning grid.

* **LASSO Model.R**
This sample shows how to create, train and evaluate
a LASSO model in R.

* **Linear Regression and Azure Web Service.R**
This sample shows how to create, train and evaluate
a linear regression model in R. It also shows how to deploy 
that model as an Azure Web Service using an [Azure Machine
Learning](https://azure.microsoft.com/en-us/services/machine-learning/)
workspace.


### Data_Exploration
  
* **Using ggplot2.R**  
This sample is an extension of the `A First Look at R/Introduction to ggplot2.R` sample.
It gives a more extensive tour of ggplot2's functionality including 3D plotting.

* **Import Data from URL.R**
This sample shows how to load a URL-identified data file into R.

* **Import Data from URL to xdf.R**
This sample shows how to load a URL-identified data file into MRS as an xdf.
It requires that MRS be installed.




