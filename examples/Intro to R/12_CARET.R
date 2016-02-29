# ---	
# title: "12 - CARET"	
# author: "Joseph Rickert"	
# date: "Wednesday, September 03, 2014"	
# output: html_document	
# ---	
### INTRODUCTION TO THE CARET PACKAGE	

# caret is the most feature rich package for doing data mining in R. This script explores caret's capabilities using data included in the  package that was described in the paper: Hill et al "Impact of image segmentation on high-content screening data quality for SK-BR-3 cells" BMC fioinformatics (2007) vol 8 (1) pp. 340	

# The analysis presented here is based on examples presented by Max Kuhn, caret's author, at Use-R 2012.	

#### Background	
# "Well-segmented"" cells are cells for which location and size may be accurrately detremined through optical measurements. Cells that are not Well-segmented (WS) are said to be "Poorly-segmented"" (PS).	

#### Problem	
# Given a set of optical measurements can we predict which cells will be PS? This is a classic classification problem	

library(caret)	
library(rpart)  			# CART algorithm for decision trees	
library(partykit)			# Plotting trees	
library(gbm)				  # Boosting algorithms	
library(doParallel)		# parallel processing	
library(pROC)				  # plot the ROC curve	
library(corrplot)			# plot correlations	

#### Get the Data	
# Load the data and construct indices to divie it into training and test data sets.  	

data(segmentationData)  	# Load the segmentation data set	
dim(segmentationData)	
#	
trainIndex <- createDataPartition(segmentationData$Case,p=.5,list=FALSE)	
trainData <- segmentationData[trainIndex,]	
dim(trainData)	
#	
testData  <- segmentationData[-trainIndex,]	
dim(testData)	

### rpart Tree Model	
# We build a basic tree model with rpart.	

tree.mod <- rpart(Class ~ .,data=trainData,control=rpart.control(maxdepth=2))	
tree.mod	

# Visualize the tree	

tree.mod.p <- as.party(tree.mod)  	# make the tree.mod object into a party object	
plot(tree.mod.p)	


### Generalized Boosted Regression Model   	
# We build a gbm model. Note that the gbm function does not allow factor "class" variables	

gbmTrain <- trainData	
gbmTrain$Class <- ifelse(gbmTrain$Class=="PS",1,0)	
gbm.mod <- gbm(formula = Class~.,  			# use all variables	
				distribution = "bernoulli",		  # for a classification problem	
				data = gbmTrain,	
				n.trees = 2000,					        # 2000 boosting iterations	
				interaction.depth = 7,			    # 7 splits for each tree	
				shrinkage = 0.01,				        # the learning rate parameter	
				verbose = FALSE)				        # Do not print the details	
					
summary(gbm.mod)			# Plot the relative inference of the variables in the model	

# This is an interesting model, but how do you select the best values for the for the three tuning parameters?   	
#   * - n.trees   	
#   * - interaction.depth   	
#   * - shrinkage   	

# Algorithm for training the model:    	
#   * for each resampled data set do   	
#     * 		hold out some samples   	
# 		  * for each combination of the three tuning parameters   	
# 			  * do   	
# 			  * 	Fit the model on the resampled data set   	
# 				  * Predict the values of class on the hold out samples   	
# 		  * 	end   	
# 		  * Calculate AUC: the area under the ROC for each sample   	
# 		  * Select the combination of tuning parmeters that yields the best AUC   	

#  caret provides the "train" function to do all of this   	

#  The trainControl function to set the training method    	
#  Note the default method of picking the best model is accuracy and Cohen's Kappa   	

ctrl <- trainControl(method="repeatedcv",  				# use repeated 10fold cross validation	
						repeats=5,							# do 5 repititions of 10-fold cv	
						summaryFunction=twoClassSummary,	# Use AUC to pick the best model	
						classProbs=TRUE)	

# Use the expand.grid to specify the search space		
# Note that the default search grid selects 3 values of each tuning parameter	

#grid <- expand.grid(.interaction.depth = seq(1,7,by=2), # look at tree depths from 1 to 7	
#						.n.trees=seq(100,1000,by=50),	# let iterations go from 100 to 1,000	
#					.shrinkage=c(0.01,0.1))			# Try 2 values of the learning rate parameter	
	
grid <- expand.grid(.interaction.depth = seq(1,4,by=2), # look at tree depths from 1 to 4	
  					.n.trees=seq(10,100,by=10),	# let iterations go from 10 to 100	
						.shrinkage=c(0.01,0.1))			# Try 2 values of the learning rate parameter	
	
#												
set.seed(1)	
names(trainData)	
trainX <-trainData[,4:61]	
	
registerDoParallel(4)		# Registrer a parallel backend for train	
getDoParWorkers()	
	
system.time(gbm.tune <- train(x=trainX,y=trainData$Class,	
				method = "gbm",	
				metric = "ROC",	
				trControl = ctrl,	
				tuneGrid=grid,	
				verbose=FALSE))	
	

#### Tuning Results	
# ROC was the performance criterion used to select the optimal model. The final values used for the model were:   	
#   * interaction.depth = 7	
#   * n.trees = 500    	
#   * shrinkage = 0.01	


gbm.tune$bestTune	
plot(gbm.tune)  		# Plot the performance of the training models	
res <- gbm.tune$results	
names(res) <- c("depth","trees", "shrinkage","ROC", "Sens","Spec", "sdROC", "sdSens", "seSpec")	
res	
	


#### GBM Model Predictions and Performance	
# Make predictions using the test data set	

testX <- testData[,4:61]	
gbm.pred <- predict(gbm.tune,testX)	
head(gbm.pred)	

# Look at the confusion matrix  	

confusionMatrix(gbm.pred,testData$Class)   	

# Draw the ROC curve 	

gbm.probs <- predict(gbm.tune,testX,type="prob")	
head(gbm.probs)	
	
gbm.ROC <- roc(predictor=gbm.probs$PS,	
  			response=testData$Class,	
				levels=rev(levels(testData$Class)))	
gbm.ROC	
	
plot(gbm.ROC)	

# Plot the propability of poor segmentation	

histogram(~gbm.probs$PS|testData$Class,xlab="Probability of Poor Segmentation")	


###SUPPORT VECTOR MACHINE MODEL	
# We follow steps similar to those above to build a SVM mocel	

set.seed(1)	
registerDoParallel(4,cores=4)	
getDoParWorkers()	
system.time(	
  svm.tune <- train(x=trainX,	
					y= trainData$Class,	
					method = "svmRadial",	
					tuneLength = 9,					# 9 values of the cost function	
					preProc = c("center","scale"),	
					metric="ROC",	
					trControl=ctrl)	# same as for gbm above	
)		
	
svm.tune	
	
# Plot the SVM results	
plot(svm.tune,	
  metric="ROC",	
	scales=list(x=list(log=2)))	
#---------------------------------------------------	
# SVM Predictions	
svm.pred <- predict(svm.tune,testX)	
head(svm.pred)	
	
confusionMatrix(svm.pred,testData$Class)	

### Comparing Models	
# Having set the seed to 1 before running gbm.tune and svm.tune we have generated paired samples (See Hothorn at al, "The design and analysis of benchmark experiments-Journal of Computational and Graphical Statistics (2005) vol 14 (3) pp 675-699) and are in a position to compare models using a resampling technique.	

# The resamples function in caret collates the resampling results from the two models   	


rValues <- resamples(list(svm=svm.tune,gbm=gbm.tune))	
rValues$values	
summary(rValues)	
xyplot(rValues,metric="ROC")  	    # scatter plot	
bwplot(rValues,metric="ROC")		    # boxplot	
parallelplot(rValues,metric="ROC")	# parallel plot	
dotplot(rValues,metric="ROC")		    # dotplot	
splom(rValues,metric="ROC")	


