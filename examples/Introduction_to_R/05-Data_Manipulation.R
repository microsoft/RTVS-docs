# ---	
# title: "5 - Data Manipulation"	
# ---	

# The checkpoint function installs all required dependencies (i.e. CRAN packages)
# you need to run the examples.
if (!require(checkpoint, quietly = TRUE))
  install.packages("checkpoint")
library(checkpoint)
checkpoint("2016-01-01")


# In this script we will show some basic data wrangling. 	

### Fetch some data from Yahoo Finance  	
# Go to http://finance.yahoo.com/q/hp?s=IBM+Historical+Prices and copy the link to the table. Then read the data directly from the URL into an R data frame.	

(if (!require("compare")) install.packages("compare"))
library("compare")
(if (!require("plyr")) install.packages("plyr"))
library("plyr")
	
url <- "http://ichart.finance.yahoo.com/table.csv?s=IBM&a=00&b=2&c=1962&d=11&e=22&f=2011&g=d&ignore=.csv"	
IBM.stock <- read.table(url,header=TRUE,sep=",")	
head(IBM.stock)	

# Having taken the trouble to fetch the data from the web we will then show how to write it to disk and read it back into a different data frame.	

write.csv(IBM.stock,file="IBM.stock.csv",row.names=FALSE)	
IBM_too  <- read.csv("IBM.stock.csv")	

### Augment the data frame	
# Here are two ways to add a new variable, Volatility, to a data frame, The first uses "$" to index into the data frame, The second uses the within function	

IBM.stock$Volatility<- (IBM.stock$High - IBM.stock$Low)/IBM.stock$Open	
head(IBM.stock)	
# Alternative using within	
IBM.stock2 <- within(IBM.stock,{Volatility = (High - Low)/Open})	
head(IBM.stock2)	

### Prune the data frame	
# We show two was to prune the data frame so that it only include prices after January 1, 2000. Note that both methods use row, column indexing into the data frame IBM.stock[row,column]. The first thing we do is check to see what data types the varables are. Noticing that Date is a factor, we willmake it a date as we build a new data frame.	

sapply(IBM.stock,class)  		# Note that Date is a factor	
	
IBM.stock.2000 <- IBM.stock[as.Date(IBM.stock$Date) > as.Date('2000-01-01'),]	
head(IBM.stock.2000)	
tail(IBM.stock.2000)	

# The second method uses the which() function. First, we build a simple example to show how which() works.	

xx <- 1:10	
which(xx > 5)	
#which(as.Date(IBM.stock$Date) > as.Date('2000-01-01'))	
IBM.stock2.2000 <- IBM.stock[which(as.Date(IBM.stock$Date) > as.Date('2000-01-01')),]	
tail(IBM.stock2.2000)	

### Aggregate data	
# Here we will aggregate daily observations to form a monthly series. First we will create new year and month variables by extracting the relevant information from the Date variable	

IBM.stock.2000$Month <- substr(IBM.stock.2000$Date,6,7)  		# Add variable Month to data frame	
IBM.stock.2000$Year  <- substr(IBM.stock.2000$Date,1,4)			# Add variable Year to the data frame	
head(IBM.stock.2000)	

# Make a new data frame to hold the aggregated monthly prices.	

IBM.stock.month <- aggregate(.~Month+Year,data=IBM.stock.2000,mean) # The dot in the formula stands for everything	
head(IBM.stock.month)	

# Make a date variable in IBM.stock.month and assign everything to the first of the month	

IBM.stock.month$Date <- as.Date(paste(IBM.stock.month$Year,IBM.stock.month$Month,'01',sep='-'))	
head(IBM.stock.month)	

# Now sort the data frame to get the latest data first	

IBM.stock.month <- IBM.stock.month[with(IBM.stock.month,order(-as.integer(Year),Month)),]	
head(IBM.stock.month)	

### Merge data	
# We will merge the the data frame containing the aggregated monthly stock prices from the year 2000 to the present with a new data frame containing dividend data. First we get the dividend data.	

url2 <- "http://ichart.finance.yahoo.com/table.csv?s=IBM&a=00&b=2&c=1962&d=11&e=22&f=2011&g=v&ignore=.csv"	
IBM.div <- read.table(url2,header=TRUE,sep=",")	
#write.csv(IBM.div,"IBM.div.csv",row.names=FALSE)	
head(IBM.div)	
#	
class(IBM.stock.month$Date)	
class(IBM.div$Date)	

# Make the IBM.div date into a proper date object	

IBM.div$Date <- as.Date(IBM.div$Date)	
class(IBM.div$Date)	

# Next we write a function to Create a column for the merge picking the last dividend dispersed before the merge.	

fcn <- function(x){	
  as.character(IBM.div$Date[min(which(IBM.div$Date < x))])	
	}	
IBM.stock.month$divDate <- sapply(IBM.stock.month$Date,fcn)	
IBM.stock.month$divDate <- as.Date(IBM.stock.month$divDate)	
head(IBM.stock.month)	

# Do the merge	

IBM <- merge(IBM.stock.month,IBM.div,by.x='divDate',by.y='Date')	
head(IBM)	
class(IBM$divDate)	
IBM1 <- IBM[order(-as.integer(as.Date(IBM$divDate))),]	
head(IBM1)	

### Is there an easirer way to merge?	
# Lets try using the join function from the plyr package.	

head(IBM.stock.month)	
head(IBM.div)	
names(IBM.div)[1] <- "divDate"	
#	
IBM2 <- join(IBM.stock.month,IBM.div,by='divDate')	
head(IBM2)	

# Sort both data frames to compare them.	

IBMs <- IBM[order(-as.integer(as.Date(IBM$Date))),]	
head(IBMs)	
IBM2s <- IBM2[order(-as.integer(as.Date(IBM2$Date))),]	
head(IBM2s)	

### Comparing data frames	
# Have a look at the vignette for the compare package	
# http://cran.r-project.org/web/packages/compare/vignettes/compare-intro.pdf	

comparison <- compare(IBMs,IBM2s,allowAll=TRUE)	
comparison$result	

### Reshaping a data frame	
# Finaly, let's look at using the reshape function to make "wide" and "long" versions of the data set.	

IBM.wide <- reshape(IBM[,c("Year","Month","Close")],idvar="Year",timevar="Month",direction="wide")	
IBM.wide	
IBM.long <- reshape(IBM.wide,idvar="Year",timevar="Month",direction="long")	
head(IBM.long, n=20)	

## The dplyer Package	
# So far, we have been looking mostly at base R data manipulation techniques. But for the past year or so "state-of-the-art"" data wrangling with R is accomplished through Hadley Wichham's dplyr package. Let's look at Hadly's tutorial in his online vignette.	
# http://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html	
# C:/Users/Joe.Rickert/Documents/RStudio Projects/Bootcamp_DataWeek_2014/Introduction to dplyr.htm	
