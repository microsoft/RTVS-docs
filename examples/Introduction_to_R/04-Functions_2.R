# ---	
# title: "4 - Functions 2"	
# ---	

# The checkpoint function installs all required dependencies (i.e. CRAN packages)
# you need to run the examples.
if (!require("checkpoint", quietly = TRUE))
  install.packages("checkpoint")
library("checkpoint")
checkpoint("2016-01-01")


### A SECOND LOOK AT R FUNCTIONS	

#### Some Properties of Functions:	

# Functions have formals(), body() and a parent environment(). These are functions that are helpful for looking at other functions.	
# formals() returns the formal arguments of a function.	

formals(rnorm)    	# returns the formal arguments of a function	

# body() returns thd body of a function. For rnorm(), the body contains .External() which is an internal function to call C/C++ code.	

body(rnorm)	

# environment() returns the parent environment of a function.	

environment(rnorm)		# returns the environment of a function	

# For a great discussin or Environments in R see the Environments chapter of Hadley Wickham's advanced R book:   	
# http://adv-r.had.co.nz/Environments.html  	


#### Anonymous Functions       	

# Functions in R are ordinary objects. You don't have to assign them a name they can be anonymous. For example:	

function(x) x + cos(x)		# define the function	
(function(x) x + cos(x))(pi)  # call the function	

# When are anonymous functions useful?	

mtcars	
lapply(mtcars, function(x) length(unique(x)))	


#### Closure  
	
# R uses lexical scoping: The binding of symbols to values depends on what was available in the function's environment at the time the function was created. This is called the enclosing environment.	

x <- 5	
f <- function(){	
	 y <- 10	
	 x + y	
}	
f()	
	
f2 <- function(){	
	  x <- 20	
	  y <- 10	
	  x + y	
}	
f2()	
#	
x	
#	
environment(f)	

# If a variable is not in the current environment R looks in the parent environment. Use search() to see the hierarchy of environments R will search.	

search()	

# Here, a new environment is created withing the body of f3	

x <- 5	
y <- 10	
	
	
f3 <- function(){	
	x <- 1	
	function(){	
		y <- 2	
		x + y	
	}	
}	
f3           # Lists the body of the function f3	
f3()         # Lists the body of the internal function	
f3()()       # Evaluates the internal function	

# To make something internal to a function available in the parent environment use the <<- asignment operator. This is generally considered to be bad practice.	

f4 <- function(x){	
	y <<-10	
	x + y	
}	
f4(5) 	
y          # is availeble in the global environment	
	
f5 <- function(x){	
	y <- 10	
	s <- x + y	
	c <- list(x,s)	
	return(c)	
	}	
	
f5(5)     # f5 picks up y	


#### Functions that need functions   	

head(iris)	
sapply(iris,class)					          # applies function to every column of a data frame	
irisF <- Filter(is.factor,iris)       # Keeps the data that are TRUE	
class(irisF)	
head(irisF)	

irisN <- Find(is.numeric,iris)        # Find the first value TRUE	
class(irisN)	
head(irisN)	

Position(is.factor,iris)            # Find the poistion of first TRUE value	
# some math functions	
integrate(sin,0,pi/2)	
optimise(sin,c(0,pi),maximum=TRUE)  	


#### tapply	

# tapply() applies a function to each cell of a ragged array. A ragged array is an array (vector, matrix, etc.) organized into groups by a factor variable where some of the levels of the factor may have zero entries.   	

n <- 17	
x <- 1:n	
group <- factor(rep(1:3, length = n), levels = 1:5)		 # Create the group	
group	
table(group)											                     # some levels are empty	
df <- data.frame(x,group)								               # build a data frame	
df	
tapply(df$x, df$group, sum)								             # Sum x by group	
class(tapply(df$x, df$group, sum))	
tapply(df$x, df$group, range)	
tapply(df$x, df$group, quantile)	
tapply(df$x,df$group,min)	
#	
myFcn <- function(n){min(n) + 4}						           # write your own function	
tapply(df$x,df$group,myFcn)								             # tapply your own function   	


#### Recursive functions	

myLog <- function(x){	
	     return(ifelse(x > 1,Recall(log(x)),x))	
		}			
myLog(5)   	

##### Some Resources	

# Hadley Wickham's book: Advanced R http://adv-r.had.co.nz/   	
# A Berkeley Workshop: http://www.stat.berkeley.edu/~statcur/Workshop2/Presentations/functions.pdf    	
# A Google Movie: http://www.youtube.com/watch?v=CHmmHfJ8hCA&list=PLOU2XLYxmsIK9qQfztXeybpHvru-TrqAP	
