# ----------------------------------------------------------------------------
# purpose:  fit a gradient boosting machine model
# audience: you are expected to have some prior experience with R
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# load packages
# ----------------------------------------------------------------------------
(if (!require("MASS")) install.packages("MASS"))
library("MASS") # to use the Boston dataset
(if (!require("gbm")) install.packages("gbm"))
library("gbm") # Gradient Boosting Machine package

# ----------------------------------------------------------------------------
# fit the model and draw some plots
# ----------------------------------------------------------------------------
# the four hyper-parameters used here - n.trees, interaction.depth, 
# n.minobsinnode, and shrinkage - were selected from cross-validation 
fit_gbm <- gbm(medv ~ .,
               distribution = "gaussian",
               n.trees = 5000,
               interaction.depth = 4,
               n.minobsinnode = 1,
               shrinkage = 0.01,
               cv.folds = 5,
               data = Boston)

# print the model
print(fit_gbm)

# check performance using 5-fold cross-validation
best.iter <- gbm.perf(fit_gbm, method = "cv")

# check variable importance
f_imp <- summary(fit_gbm, n.trees = best.iter, plot = FALSE)

# use a custom plot to show variable importance
barplot(f_imp$rel.inf, names.arg = f_imp$var, xlab = "Feature", 
        ylab = "Relative influence", cex.names = 0.8)
