# ---	
# title: "11 - SQLite"	
# ---	

# The checkpoint function installs all required dependencies (i.e. CRAN packages)
# you need to run the examples.
if (!require(checkpoint, quietly = TRUE))
  install.packages("checkpoint")
library(checkpoint)
checkpoint("2016-01-01")


### READING FROM A SQL DATABASE	
# This script creates a SQLite database from a csv file using the RSQlite library. Then a simple query is sent to the database.	

(if (!require("DBI")) install.packages("DBI"))
library("DBI")	
(if (!require("RSQLite")) install.packages("RSQLite"))
library("RSQLite")
(if (!require("recommenderlab")) install.packages("recommenderlab"))
library("recommenderlab")

# Point to the file and read it in	

data(diamonds, package = "ggplot2")
diamondsFile <- tempfile(fileext = ".csv")
write.csv(diamonds, file = diamondsFile, row.names = FALSE)
head(diamonds)

# set up the database connection	

con <- dbConnect(dbDriver("SQLite"), dbname = "gemstones")	
print(con)

# Write a table to the database	
# Note that dbWriteTable automatically defines columns names from csv input
dbWriteTable(con, name = "diamonds", value = diamondsFile, overwrite = TRUE)	
#	
dbListTables(con)
dbListFields(con, "diamonds")

# Generate a simple query	

result <- dbGetQuery(con,	
  				"SELECT * 	
						FROM diamonds	
            WHERE price > 10000 "
  )	
head(result)
nrow(result)

	





