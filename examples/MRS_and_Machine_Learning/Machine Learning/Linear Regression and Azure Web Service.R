## This script shows hpw to fit a linear regression model and 
## deploy an Azure ML web service.

cat("-----------------------------------------------------------------\n",
    "NOTE:In order to run the last part of the script you 'll need to have \n",
    "the an Azure ML workspace, with its workspace ID and key. \n",
    "For details about Azure ML, go to http://studio.azureml.net/ \n")

# Enter your Azure ML Studio workspace info here before continuing.
ws_id <- ""
auth_token <- ""

# Load packages.
# Install packages if they are not already installed.
# Load the package for deploying Azure ML web service.
(if (!require("AzureML", quietly = TRUE)) install.packages("AzureML"))
library("AzureML")
# To use the Boston dataset.
(if (!require("MASS", quietly = TRUE)) install.packages("MASS"))
library("MASS")
# Used for plotting.
if (!require("ggplot2", quietly = TRUE)) install.packages("ggplot2")
library("ggplot2") 


### Fit a model and check model performance.

# Check the data.
head(Boston)
ggplot(Boston, aes(x=medv)) + 
  geom_histogram(binwidth=2) +
  ggtitle("Histogram of Response Variable")

# Fit a model using medv as response and others as predictors. 
lm1 <- lm(medv ~ ., data = Boston)

# Check model performance.
summary(lm1)

pred <- predict(lm1)
mae <- mean(abs(pred - Boston$medv))
rmse <- sqrt(mean((pred - Boston$medv) ^ 2))
rae <- mean(abs(pred - Boston$medv)) / mean(abs(Boston$medv - 
                                                  mean(Boston$medv)))
rse <- mean((pred - Boston$medv) ^ 2) / mean((Boston$medv - 
                                                mean(Boston$medv)) ^ 2)

print(paste("Mean Absolute Error: ", 
            as.character(round(mae, digit = 6)), sep = ""))
print(paste("Root Mean Squared Error: ", 
            as.character(round(rmse, digit = 6)), sep = ""))
print(paste("Relative Absolute Error: ", 
            as.character(round(rae, digit = 6)), sep = ""))
print(paste("Relative Squared Error: ", 
            as.character(round(rse, digit = 6)), sep = ""))

### Publish and consume a web service.

# The following works only with valid AzureML workspace information: 
# Get workspace information.
AML <- 0
tryCatch(
  {
    ws <- workspace(id = ws_id, auth = auth_token)
    AML <- 1
  },
  error = function(cond){
    cat("-----------------------------------------------------------------\n", 
      "Azure ML workspace information is invalid. \n")
  }
)

if (AML) {
  # Define predict function.
  mypredict <- function(newdata) {
    res <- predict(lm1, newdata)
    res
  }
  
  # Test the prediction function.
  newdata <- Boston[1, 1:13]
  print(mypredict(newdata))
  
  # Publish the service.
  ep <- publishWebService(ws = ws,
                          fun = mypredict, 
                          name = "HousePricePrediction",
                          inputSchema = newdata)
  
  # Consume web service - 1st approach:
  pred <- consume(ep, newdata)
  pred
  
  # Consume web service - 2nd approach:
  # Retrieve web service information for later use.
  service_id <- ep$WebServiceId
  # Define endpoint.
  ep_price_pred <- endpoints(ws, service_id)
  # Consume.
  consume(ep_price_pred, newdata)
  
  # Define function for testing purposes.
  mypredictnew <- function(newdata) {
    res <- predict(lm1, newdata) + 100
    res
  }
  
  # Update service with the new function.
  ep_update <- updateWebService(
    ws = ws,
    fun = mypredictnew,
    inputSchema = newdata,
    serviceId = ep$WebServiceId)
  
  # Consume the updated web service.
  consume(ep_price_pred, newdata)
} else {
    cat("-----------------------------------------------------------------\n",
    "Azure ML webservice was not deployed because",
    "the workspace information is invalid. \n")
}