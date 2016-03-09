# ---	
# title: "3 - Data Structures"	
# ---	

# The checkpoint function installs all required dependencies (i.e. CRAN packages)
# you need to run the examples.
if (!require("checkpoint", quietly = TRUE))
  install.packages("checkpoint")
library("checkpoint")
checkpoint("2016-01-01")

### Vectors	

v <- 10           # or v = 10 	
v	

### Attributes	

# Many R objects have a class attribute, a character vector giving the names 
# of the classes from which the object inherits. If the object does not have 
# a class attribute, it has an implicit class,  "matrix", "array" or the result 
# of mode(x) except that integer vectors have implicit class "integer"  	


class(v)	
length(v)	
v1 <- seq(1,50,by=5)     # R has many ways to generate sequences	
mode(v1)	
class(v1)	
length(v1)	


### Vector Operations	

v1[5]                    # Index into a vector	
	
v2 <- 1:10               # another way to generate a sequence	
v2	

s <- v1 + v2             # add vectors element by element	
s	

p <- v1 * v2             # multiply element by element	
p	

s[v2 > 5]              # index into one vector using a function on another vector	


### Character Vectors  	

c1 <- c("ABC","DEF")  	# build your own character vector  	
c1  	
mode(c1)  	
class(c1)  	
length(c1)  	

c2 <- c("2","3")  	
c2  	
mode(c2)  	
class(c2)  	
length(c2)  	

v3 <- as.integer(c2)		# make character vector into an integer  	
v3  	
mode(v3)  	
class(v3)  	
length(v3)  	

v4 <- runif(10) > .5		# create a logical vector  	
v4  	
mode(v4)  	
class(v4) 	

### Matrices	

m1 <- matrix(1:100,nrow=10,ncol=10,byrow=TRUE)  	
m1  	
mode(m1)  	
class(m1)  	
length(m1)  	
dim(m1)  	
m1[5,5]  					# index into the matrix	  		


### Some Elementary Matrix Functions	
m1^2						# square elements	
sqrt(m1)	
m2 <- matrix(1:100,nrow=10,ncol=10)	
m2	
m1 + m2						# add 2 matrices elementwise	
m1 * m2						# multiply 2 matrices elementwise	
m1 %*% m2					# matrix multiplication	
c3 <- subset(letters,letters!="z")	
c3	
m3 <- matrix(c3,nrow=5)		# matrix of characters	
m3	
mode(m3)	
class(m3)	

### Outer Product	

x <- y <- 1:9	
names(x) <- x	
x	
names(y) <- paste(y,":",sep="")	
y	
# 	
y %o% x						# Multiplication table	
outer(y, x, "^")			# Table of Powers	

### Lists	

li <- list(v,v1,v2,v3,c1,list(m1,m2),c3,m3)	
li	
mode(li)	
class(li)	
length(li)	
li[[6]][2]  				# Index into a list	


### Data Frames	

a <- 1:10	
b <- letters[1:10]	
c <- LETTERS[11:20]	
d <- 100:91	
dF <- data.frame(a,b,c,d)	
dF	
mode(dF)	
class(dF)	
length(dF)	
dim(dF)	

names(dF) <- c("var1", "var2", "var3", "var4") # Give names to the variables in the data frame  	
dF	

### Factors  	

lapply(dF,class)  # Find the class of each variable	
  								# R automatically made the character strings into factors	
levels(dF$var2)   #    Factors are categorical variables with levels	
dF$var2 <- as.character(dF$var2)  	# force v2 to be character data	

class(dF$var2)	
attach(dF)						# Make Data Frame columns available as variables in the global environment	
var2	

