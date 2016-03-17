# ----------------------------------------------------------------------------
# purpose:  fit a linear regression model and deploy an Azure ML web service
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# NOTE: In order to run the last part of the script you'll need to have
# the an Azure ML workspace, with its workspace ID and key.
# For details about Azure ML, go to http://studio.azureml.net/
# ----------------------------------------------------------------------------
# Enter your Azure ML Studio workspace info here before continuing.
ws_id <- ""
auth_token <- ""

# ----------------------------------------------------------------------------
# load packages
# ----------------------------------------------------------------------------
# install packages if they are not already installed
(if (!require("AzureML", quietly = TRUE)) install.packages("AzureML"))
library("AzureML") # load the package for deploying Azure ML web service
(if (!require("MASS", quietly = TRUE)) install.packages("MASS"))
library("MASS") # to use the Boston dataset
if (!require("ggplot2", quietly = TRUE)) install.packages("ggplot2")
library("ggplot2") # used for plotting

# ----------------------------------------------------------------------------
# fit a model and check model performance
# ----------------------------------------------------------------------------
# check the data
head(Boston)
ggplot(Boston, aes(x=medv)) + 
  geom_histogram(binwidth=2) +
  ggtitle("Histogram of Response Variable")

# fit a model using medv as response and others as predictors 
lm1 <- lm(medv ~ ., data = Boston)

# check model performance
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

# ----------------------------------------------------------------------------
# publish and consume a web service
# ----------------------------------------------------------------------------
# the following works only with valid AzureML workspace information 

# get workspace information
AML <- 0
tryCatch(
  {
    ws <- workspace(id = ws_id, auth = auth_token)
    AML <- 1
  },
  error = function(cond){
    message("Azure ML workspace information was not valid.")
  }
)

if (AML) {
  # define predict function
  mypredict <- function(newdata) {
    res <- predict(lm1, newdata)
    res
  }
  
  # test the prediction function
  newdata <- Boston[1, 1:13]
  print(mypredict(newdata))
  
  # Publish the service
  ep <- publishWebService(ws = ws, fun = mypredict, 
                          name = "HousePricePrediction", inputSchema = newdata)
  
  # consume web service - 1st approach
  pred <- consume(ep, newdata)
  pred
  
  # consume web service - 2nd approach
  # retrieve web service information for later use
  service_id <- ep$WebServiceId
  # define endpoint
  ep_price_pred <- endpoints(ws, service_id)
  # consume
  consume(ep_price_pred, newdata)
  
  # define function for testing purpose
  mypredictnew <- function(newdata) {
    res <- predict(lm1, newdata) + 100
    res
  }
  
  # update service with the new function
  ep_update <- updateWebService(
    ws = ws,
    fun = mypredictnew,
    inputSchema = newdata,
    serviceId = ep$WebServiceId)
  
  # consume the updated web service
  consume(ep_price_pred, newdata)
} else {
  message("Azure ML webservice is not deployed because ", 
          "the workspace information is invalid")
}