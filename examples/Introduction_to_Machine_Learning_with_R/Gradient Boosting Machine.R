# ----------------------------------------------------------------------------
# purpose:  fit a gradient boosting machine model
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# load packages
# ----------------------------------------------------------------------------
(if (!require("MASS")) install.packages("MASS"))
library("MASS") # use the mvrnorm function
(if (!require("caret")) install.packages("caret"))
library("caret") # use the train function for selecting hyper parameters
(if (!require("gbm")) install.packages("gbm"))
library("gbm") # Gradient Boosting Machine package

# ----------------------------------------------------------------------------
# select hyper parameters
# ----------------------------------------------------------------------------
# ensure results are repeatable
set.seed(123)

# prepare training scheme
control <- trainControl(method = "cv", number = 5)

# design the parameter tuning grid 
grid <- expand.grid(n.trees = c(5000, 10000, 15000),
                    interaction.depth = c(2, 4, 8),
                    n.minobsinnode = c(1, 2, 4),
                    shrinkage = c(0.001, 0.01, 0.1))

# design the parameter tuning grid - smaller grid for testing purpose
# grid <- expand.grid(n.trees = c(5000, 10000),
#                     interaction.depth = c(2, 4),
#                     n.minobsinnode = c(1, 2),
#                     shrinkage = c(0.001, 0.01))

# tune the parameters
gbm1 <- train(medv ~ ., data = Boston, method = "gbm", 
              distribution = "gaussian", trControl = control, 
              verbose = FALSE, tuneGrid = grid, metric = "RMSE")

# summarize the model
print(gbm1)

# plot cross-validation results
plot(gbm1)

# ----------------------------------------------------------------------------
# fit the model with estimated hyper parameters and draw some plots
# ----------------------------------------------------------------------------
gbm2 <- gbm(medv ~ .,
            distribution = "gaussian",
            n.trees = 5000,
            interaction.depth = 4,
            n.minobsinnode = 1,
            shrinkage = 0.01,
            cv.folds = 5,
            data = Boston)

# print the model
print(gbm2)

# check performance using 5-fold cross-validation
best.iter <- gbm.perf(gbm2, method = "cv")

# check variable importance
f_imp <- summary(gbm2, n.trees = best.iter, plot = FALSE)

# use a custom plot to show variable importance
barplot(f_imp$rel.inf, names.arg = f_imp$var, xlab = "Feature", 
        ylab = "Relative influence", cex.names = 0.8)
