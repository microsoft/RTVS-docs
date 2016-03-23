## This script shows how to fit a LASSO model.

# To learn more about LASSO, refer to:
# http://statweb.stanford.edu/~tibs/lasso.html

# Load packages.
suppressWarnings(if (!require("glmnet", quietly = TRUE))
    install.packages("glmnet"))
library("glmnet") # use this package to fit a glmnet model
suppressWarnings(if (!require("MASS", quietly = TRUE))
    install.packages("MASS"))
library("MASS") # to use the Boston dataset

# Identify the optimal value of lambda.
# Define response variable and predictor variables.
response_column <- which(colnames(Boston) %in% c("medv"))
train_X <- data.matrix(Boston[, - response_column])
train_y <- Boston[, response_column]

# Use cv.glmnet with 10-fold cross-validation to pick lambda.
print("Started fitting LASSO")
model1 <- cv.glmnet(x = train_X, y = train_y, alpha = 1, nfolds = 10,
                    family = "gaussian", type.measure = "mse")
print("Finished fitting LASSO")
plot(model1)

# Print out the optimal lambdas.
cat("Lambda that gives minimum mean cross-validated error:",
    as.character(round(model1$lambda.min, 4)), "\n\n")
cat("Largest lambda with mean cross-validated error",
    "within 1 standard error of the minimum error:",
    as.character(round(model1$lambda.1se, 4)), "\n\n")
cat("Coefficients based on lambda that", 
    " gives minimum mean cross-validated error: \n")
print(coef(model1, s = "lambda.min"))

# Check how lambda impacts the estimated coefficients.
model2 <- glmnet(x = train_X, y = train_y, alpha = 1, family = "gaussian")

# Identify variable names.
vn = colnames(train_X)
vid <- as.character(seq(1,length(vn)))

# Check and exclude the variables with coefficient value 0. 
vnat = coef(model2)
vnat_f <- vnat[-1, ncol(vnat)] 
vid <- vid[vnat_f != 0]
vn <- vn[vnat_f != 0]

# Define the legend description, line type, and line color.
nvars <- length(vn)
legend_desc <- paste(vid, vn, sep=": ")
legend_desc
mylty <- rep(1,nvars)
mycl <- seq(1,nvars)

# Plot
plot(model2, xvar = "lambda", label = TRUE, col = mycl, xlim = c(-5.5, 2))
legend(-0.5,-2, legend_desc, lty = mylty, col = mycl, cex = 0.8) 


### Make predictions.

x_new <- data.matrix(train_X[1:2, - response_column])

# Make predictions with model 1.
predictions_train <- predict(model1, newx = x_new, s = "lambda.min")
print(predictions_train)

# Make predictions with model 2.
predictions_train2 <- predict(model2, newx = x_new, s = model1$lambda.min)
print(predictions_train2)
