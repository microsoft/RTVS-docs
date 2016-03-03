# ---	
# title: "Introduction to R"	
# ---	

# The checkpoint function installs all required dependencies (i.e. CRAN packages)
# you need to run the examples.
if (!require(checkpoint, quietly = TRUE))
  install.packages("checkpoint")
library(checkpoint)
checkpoint("2016-01-01")

## Getting Started  	
# Data Week 2014 R Bootcamp   	
# Copyright: Revolution Analytics  	
# This document is licensed under the GPLv2 license: http://www.gnu.org/licenses/gpl-2.0.html  	

### Some Brief History	
# R followed S. The S language was conceived by John Chambers, Rick Becker, Trevor Hastie, Allan Wilks and others at Bell Labs in the mid 1970s. S was made publically available in the early 1980’s. R, which is modeled closely on S, was developed by Robert Gentleman and Ross Ihaka in the early 1990's while they were both faculty members at the University of Auckland. R was established as an open source project (www.r-project.org) in 1995. Since 1997 the R project has been managed by the R Core Group. When AT&T spun of Bell Labs in 1996, S was no longer freely available. S-PLUS is a commercial implementation of the S language developed by the Insightful corporation which is now sold by TIBCO software Inc.	

# The R Core Group: http://www.r-project.org/contributors.html  	
# Download R: http://cran.r-project.org/	

### How R is oganized	
# R is an interpreted functional language with objects. The core of R language contains the the data manipulation and statistical functions. Most of R's capabilities are delivered as user contributed packages that may be downloaded from CRAN.R ships with the "base and recommended" packages:	
# http://cran.r-project.org/doc/FAQ/R-FAQ.html#Which-add_002don-packages-exist-for-R_003f  	

###  R RESOURCES	
# What is R? the movie: http://www.youtube.com/watch?v=TR2bHSJ_eck   	
# Search for R topics on the web: http://www.rseek.org  	
# search or R packages: http://www.rdocumentation.org  	
# A list of R Resources: http://www.revolutionanalytics.com/what-is-open-source-r/r-resources.php    	
# Quick R: http://www.statmethods.net/  	
# R Reference Card: http://cran.r-project.org/doc/contrib/Short-refcard.pdf    	
# An online book: http://www.cookbook-r.com/  	
# Hadley Wickham's book, Advanced R: http://adv-r.had.co.nz  	
# CRAN Task Views: http://cran.r-project.org/web/views/    	  	
# Some help with packages: http://crantastic.org/  				                                   	
# the BIOCONDUCTOR PROJECT FOR GENOMICS: http://www.bioconductor.org/     	

### R Blogs	
# Revolutions blog: http://blog.revolutionanalytics.com/  	
# RBloggers: http://www.r-bloggers.com	

### Getting Help	
# If you are looking for help with technical questions about the language please consult the community site (http://www.r-project.org) for frequently asked questions. Ask for help on one of the several R mailing lists  http://www.r-project.org/mail.html or Stack Overflow http://stackoverflow.com/questions/tagged/r  	

### Packages needed for this Bootcamp	
# Package      | Use                                      | Module	
# ----------   | ----------                               | --
# ada          | Boosting library                         | 12	
# boot         | bootstrap library                        | 7	
# car          | for data sets                            | 6  	
# colorspace   | plotting colors  	
# compare      | compare data frames                      | 5 	
# corrplot     | correlation plots                        | 12	
# DBI          | database                                 | 11	
# doParallel   | backend for parallel computing           | 12 	
# e1071        | svm                                      | 12	
# ellipse      | for correlation plot                     | 8	
# fbasics      | for the plotcluster function             | 8	
# fpc          | Clustering                               | 10	
# gbm          | boosting models                          | 12	
# gplots       | for barplot                              | 8	
# ggplot2      | Plots                                    | 6, 8	
# Hmisc 	     | for describe()                           | 8, 10	
# ISwR         | FOR DATA SET                             | 2	
# kernlab      | svm                                      | 12	
# lattice      | Graphics                                 | 6	
# partyplot    | tree plots                               | 12	
# plyr         | for data data manipulation               | 5	
# pROC         | for ROC curve                            | 12	
# randomForest | randomForest classification algorithm    | 12	
# rattle       | for data mining gui and data sets        | 1, 12 	
# ROCR         | ROC                                      | 12 	
# rpart        | for classification and regression trees  | 12	
# RSOLite      | For SQLite conectivity                   | 11	
# vcd          | for rainwow_hcl colors                   | 6	

### Looking at Packages	

# library()                  # list all available installed packages	
search() # list all "attached" or loaded packages	
(if (!require("rattle")) install.packages("rattle"))
# install the package rattle if necessary	
library("rattle") # to load the package rattle	
(if (!require("RGtk2")) install.packages("RGtk2"))
library("RGtk2")
data() # to see all of the data sets available in the packages you have loaded	
data(package = "rattle") # to see all the data sets in the pakage rattle	
help(package = rattle) # to get help with the package rattle	
# lsf.str("package:rattle")  # to list all of the functions in rattle	
