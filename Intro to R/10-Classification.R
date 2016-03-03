# ---	
# title: "10 - Classification"	
# author: "Joseph Rickert"	
# date: "Friday, August 29, 2014"	
# output: html_document	
# ---	

(if (!require("rattle")) install.packages("rattle"))
library("rattle")  			# for weather data set	
(if (!require("rpart")) install.packages("rpart"))
library("rpart")				# CART Decision Trees	
(if (!require("colorspace")) install.packages("colorspace"))
library("colorspace")		# used to generate colors for plots	
(if (!require("randomForest")) install.packages("randomForest"))
library("randomForest")	
(if (!require("ROCR")) install.packages("ROCR"))
library("ROCR")				  # ROC 	
(if (!require("kernlab")) install.packages("kernlab"))
library("kernlab")			# SVM library	
(if (!require("e1071")) install.packages("e1071"))
library("e1071")				# SVM library	
(if (!require("ada")) install.packages("ada"))
library("ada")          # Boosting library	

### Some Convenience Functions	
##	

# Function to divide data into training, and test sets 	
ttIndex <- function(data=data,pctTrain=0.7)	
	{	
		# fcn to create indices to divide data into random 	
		# training, validation and testing data sets	
		N <- nrow(data)											
		trainInd <<- sample(N, pctTrain*N)									
		testInd <<- setdiff(seq_len(N),trainInd)		
  }

# Function to generate the confusion matrix and percent correct	
score <- function(model,target=data[testInd, 21],predict=pr){	
	results.test <- table(target,predict,dnn=c("Actual", "Predicted"))	
	pct.test.correct <- round(100 * sum(diag(results.test)) / sum(results.test),2)	
	results <- list(results.test,pct.test.correct)	
	(results)	
}	

### Read the Data and Prepare the Training and Test Sets	
# Get the weather data and select the subset for modeling	

data(weather)
# head(data)	
# Select variables for the model	
data <- subset(data,select=c(MinTemp:RainToday,RainTomorrow))	
set.seed(42)									# Set seed	
ttIndex(data) # Pick out rows (index into data) for the training and test data sets	

### Build a Tree Model with rpart   	

# The rpart algorithm based on recursive partitioning       	
# (See section 11.2 of Data Mining with Rattle and R by williams)   	
# The rpart Algorithm:  	
# 1. -   Partition the data set according to some criterion of "best" partition   	
# 2. -   Do the same for each of the two new subsets   	
# 3. -  Once a partition is made, stick with it (greedy approach)   	

# Measures of "best" partition:   	
# 1. -    information gain (the default)   	
# 2. -    Gini   	

# Information Gain Algorithm:   	
# For all possible splits (partitions)   	
# 1. -    Split data, D, into to subsets S1 and S2 where D = S1 U S2   	
# 2. -    Calculate information I1 and I2 associated with S1 and S2   	
# 3. -    Compute total information of split: Info(D,S1,S2) = (|D1|/D)*I1 + (|D2|/|D|)*I2   	
# 4. -    Compute the information gain of the split: info(D) - info(D,S1,S2)   	
# 5. -    Select split with greatest information gain	

#### Build a classification tree model   	

form <- formula(RainTomorrow ~ .)				# Describe the model to R	
model <- rpart(formula = form, data = data[trainInd,])	# Build the model	
#	
model		
 
#### Interpreting the Model Results     	

# Every line of the output the follows will have   	
# 1. node: a node number   	
# 2. split: the logic for how the node splits the data   	
# 3. n: the number of observations considered at that split    	
# 4. loss: the number of incorrectly classified observations   	
# 5. the majority class at that node   	
# 6. yprob: the distribution of classes at that node   	

# So for the second line above: Pressure3pm >= 1011.9 204 16 No (0.92156863 0.07843137)   	
# 1. node: 2)      	
# 2. split: if Pressure3pm > 1011.9 go left down tree   	
# 3. n: 204 obversations went down this branch      	
# 4. loss: 16 misclassified observations   	
# 5. Most observations were No   	
# 6. 92% of obs have target var No, 8% are yes   	

#### Examine the results    	

printcp(model)	
summary(model)	
#rpart:::summary.rpart	
leaf <- model$where						   # find out in which leaf each observation ended up	
leaf	

#### Plot Tree   	
#  First a Basic R plot   	

opar <- par(xpd=TRUE)							# Plotting is clipped to the figure region	
plot(model)	
text(model)	
par(opar)	

#  Now, a Rattle style plot	

drawTreeNodes(model)	
title(main="Decision Tree weather.csv $ RainTomorrow")	
	


#### Evaluate model performance on the test set 	
# Run the tree model on the test set and generate an error matrix	

  pr <- predict(model, data[testInd, ], type="class")	
# 	
score(model)                     # generate the confusion matrix      	

#### Draw the ROC Curve	
# First, create a prediction object.	

pred <- prediction(as.vector(as.numeric(pr)), data[testInd,21])	
perf <- performance(pred,"tpr","fpr")	
plot(perf, main="ROC curve", colorize = TRUE)	


#### Explore an unpruned tree	
# The complexity parameter sets the minimum benefit that must be gained at each split of the decision tree. (default = .01) Typical behavior with cp=0 is to see the error reate decrease at first and then begin to increase.	

control <- rpart.control(minsplit=10,	
						 minbucket=5,	
						 maxdepth=20,	
						 usesurrogate=0,	
						 maxsurrogate=0,	
						 cp=0,	
						 minibucket=0)	
model2 <- rpart(formula=form,control=control,data=data[trainInd,])	
print(model2$cptable)	
plotcp(model2)	
grid()	





























