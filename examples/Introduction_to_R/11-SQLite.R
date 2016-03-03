# ---	
# title: "11 - SQLite"	
# author: "Joseph Rickert"	
# date: "Wednesday, September 03, 2014"	
# output: html_document	
# ---	
### READING FROM A SQL DATABASE	
# This script creates a SQLite database from a csv file using the RSQlite library. Then a simple query is sent to the database.	

library(DBI)	
library(RSQLite)	

# Point to the file and read it in	

dirDB <- "C:/DATA/MovieLens"	
file <- file.path(dirDB,"ratings.csv")	
ratingData <- read.csv(file,sep="")	
head(ratingData)	

# set up the database connection	

con <- dbConnect(dbDriver("SQLite"),dbname="movies")	
print(con)	
# Write a table to the database	
dbWriteTable(con,"ratingTbl",ratingData)	
#	

# Generate a simple query	

result <- dbGetQuery(con,	
  				"SELECT * 	
						FROM ratingTbl	
						WHERE Rating > 3")	
head(result)	
	
lsf.str("package:RSQLite")	





