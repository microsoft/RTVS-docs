## MRS_and_Machine_Learning
This collection of examples shows how to use R and MRS to create 
machine learning models and showcases how to take advantage of the
functionality of Mircosoft R Server. In order to run scripts with 
`MRS` in the title, it will be necessary to first [install MRS]
(https://www.microsoft.com/en-us/server-cloud/products/r-server/). 

### Flight_Delays_Prediction_with_R 

* **R_Flight_Delays_with_MRS_Comparison.R**
This sample shows how to predict flight delays longer than 15 minutes using R, machine learning
and historical on-time performance and weather data . 
When paired with `MRS_Flight_Delays_with_R_Comparison.R`, it provides a step-by-step comparison 
of the functionality of open source R (a.k.a. CRAN R) and Microsoft R Server. 

### Flight_Delays_Prediction_with_MRS

* **MRS_Flight_Delays_with_R_comparison.R**
This sample shows how to predict flight delays longer than 15 minutes using R, machine learning
and historical on-time performance and weather data . 
When paired with `MRS_Flight_Delays_with_MRS_Comparison.R`, it provides a step-by-step comparison 
of the functionality of open source R (a.k.a. CRAN R) and Microsoft R Server. 

* **MRS_Flight_Delays.R**
This sample shows how to build the same model as `MRS_Flight_Delays_with_R_comparison.R`, but 
uses MRS best practices and syntax, which can differ substantially from those of R.
  
### Bike_Rental_Estimation_with_MRS

* **MRS_Bike_Rental_Estimation.R** 
  This sample creates a demand prediction model for bike rentals based on a historical data set.
  It uses Microsoft R Server.

### R_MRO_MRS_Comparison

* **R_MRO_MRS_Comparison_Part_1_Functions.R**
* **R_MRO_MRS_Comparison_Part_2_Capacity.R**
* **R_MRO_MRS_Comparison_Part_3_Speed.R**

These samples show where the commands, syntax, constructs and performance of 
R, Microsoft R Open and Microsoft R Server are similar, and where they differ.
 
### Comparisons

* **MRO-MKL-benchmarks.R** 
Microsoft R Open includes the Intel Math Kernel Library (MKL) 
for fast, parallel linear algebra 
computations. This script runs performance benchmarks using different 
numbers of threads. It requires MRS to be installed.

* **rxGlm-benchmark.R**
This sample demonstrates how to fit a logistic regression using CRAN R,
and how the rxGlm() function is dramatically faster and more scalable
NOTE: The CRAN portion of this comparison requires about 7GB of RAM.
If your machine has less, this script will crash.
  
### Machine Learning  
  
* **Gradient Boosting Machine.R**
This sample shows how to create, train and evaluate
a gradient boosting machine model in R.

* **LASSO Model.R**
This sample shows how to create, train and evaluate
a LASSO model in R.

* **Linear Regression and Azure Web Service.R**
This sample shows how to create, train and evaluate
a linear regression model in R. It also shows how to deploy 
that model as a web service in Azure Machine Learning.

### Data_Exploration
  
* **Using_ggplot2.R**  
This sample is an extension of the `A_First_Look_at_R/Introduction_to_ggplot2.R` sample.
It gives a more extensive tour of ggplot2's functionality including 3D plotting.

* **Import_Data_from_URL.R**
This sample shows how to load a URL-identified data file into R.

* **Import_Data_from_URL_to_xdf**
This sample shows how to load a URL-identified data file into MRS as an xdf.
It requires that MRS be installed.
