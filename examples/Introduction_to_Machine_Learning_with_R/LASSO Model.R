# ----------------------------------------------------------------------------
# purpose:  fit a LASSO, 
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# to learn more about LASSO, refer to:
# http://statweb.stanford.edu/~tibs/lasso.html

# ----------------------------------------------------------------------------
# load packages
# ----------------------------------------------------------------------------
(if (!require("glmnet")) install.packages("glmnet"))
library("glmnet") # use this package to fit a glmnet model
(if (!require("MASS")) install.packages("MASS"))
library("MASS") # use the Boston dataset

# ----------------------------------------------------------------------------
# identify the optimal value of lambda
# ----------------------------------------------------------------------------
# define response variable and predictor variables
response_column <- which(colnames(Boston) %in% c("medv"))
train_X <- data.matrix(Boston[, - response_column])
train_y <- Boston[, response_column]

# use cv.glmnet with 10-fold cross-validation to pick lambda
print("Started fitting LASSO")
model1 <- cv.glmnet(x = train_X, y = train_y, alpha = 1, nfolds = 10,
                    family = "gaussian", type.measure = "mse")
print("Finished fitting LASSO")
plot(model1)

# print out the optimal lambdas
cat("Lambda that gives minimum mean cross-validated error:",
    as.character(round(model1$lambda.min, 4)), "\n\n")
cat("Largest lambda with mean cross-validated error",
    "within 1 standard error of the minimum error:",
    as.character(round(model1$lambda.1se, 4)), "\n\n")
cat("Coefficients based on lambda that", 
    " gives minimum mean cross-validated error: \n")
print(coef(model1, s = "lambda.min"))

# ----------------------------------------------------------------------------
# check how lambda impacts the estimated coefficients
# ----------------------------------------------------------------------------
model2 <- glmnet(x = train_X, y = train_y, alpha = 1, family = "gaussian")
plot(model2, xvar = "lambda", label = TRUE)

# add labels for variables
vn = colnames(train_X)
par(mar = c(5, 4, 4, 2) + 0.1)
vnat = coef(model2)
# remove the intercept, and get the coefficients at the end of the path
vnat = vnat[-1, ncol(vnat)] 

axis(4, at = vnat, line = -.5, label = vn, las = 1, tick = FALSE, 
     cex.axis = 0.5)

# check coefficients from using glmnet() to compare with 
# those from cv.glmnet(): the same
coef(model2, s = model1$lambda.min)

# ----------------------------------------------------------------------------
# make predictions
# ----------------------------------------------------------------------------
# make predictions with model 1
x_new <- data.matrix(train_X[1:2, - response_column])
predictions_train <- predict(model1, newx = x_new, s = "lambda.min")
print(predictions_train)

# make predictions with model 2
predictions_train2 <- predict(model2, newx = x_new, s = model1$lambda.min)
print(predictions_train2)
