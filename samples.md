---
layout: default
---

# Examples for how to use R Tools for Visual Studio

We'd like to give you a running start using R Tools for Visual Studio. Here are
some examples for how to write R code, how to make it fast and how to use
Microsoft R Server for big datasets and multi-core machines.

## Download and install

1. [Download the samples](https://github.com/Microsoft/RTVS-docs/archive/master.zip).

1. Unzip the archive open the solution by double clicking on the
   `examples\Examples.sln` file.

If you prefer to work with the examples via Github, they are all available in
the `master` branch of the [RTVS-docs repository on
Github](https://github.com/microsoft/rtvs-docs).

## Overview 

In the zip archive, there are a number of examples, grouped into different categories:

### Microsoft R Server examples

These samples show off the power of [Microsoft R
Server](https://www.microsoft.com/en-us/server-cloud/products/r-server/), which
lets you work with datasets that are too large to fit in memory.

#### Flight delay prediction

This example uses historical on-time performance and weather data to predict
whether the arrival of a scheduled passenger flight will be delayed by more than
15 minutes. It uses datasets from the Github repository for the samples. While
the datasets are relatively small for the purposes of illustration, in practice
you can scale those datasets to whatever size makes sense for your application.

#### Bike rental estimation

This example demonstrates the Feature Engineering process *TODO: need link for
the Feature Engineering process* for builing a regression model to predict bike
rental demand using historical datasets. Similar to the previous example, the
datasets are relatively small (17,379 rows and 17 columns) for the purposes of
illustration, but can be scaled to whatever size makes sense for your
application.

### Microsoft R Open (R with MKL) examples

These examples show off the power of [Microsoft R
Open](https://mran.revolutionanalytics.com/open/), Microsoft's distribution of R
which has two key differentiators over [CRAN R](https://cran.r-project.org/):

1. [Better computation
   performance](https://mran.revolutionanalytics.com/rro/#intelmkl1) when
   coupled with the [Intel Math Kernel
   Libraries](https://software.intel.com/en-us/intel-mkl) which are available as
   a free download from Microsoft for use with Microsoft R Open. 

1. [Reproducible R
   Toolkit](https://mran.revolutionanalytics.com/rro/#reproducibility), which
   ensures that the libraries that you built your R program with are always
   available to others that want to reproduce your work. -- TODO:
   do we have a sample that shows this off?

#### Benchmarks

This example runs a number of compute-intensive benchmarks to show the
performance gains that are possible through the use of the Intel Math Kernel
Libraries in Microsoft R Open.

#### Deploying an Azure Machine Learning web service

This example shows how you can create a linear regression model using R, and
then publish it as an Azure Web Service using an [Azure Machine
Learning](https://azure.microsoft.com/en-us/services/machine-learning/)
workspace *TODO: should we call it Cortana Analytics?* that you can create for
free.

### Introduction to R and Machine Learning

#### Gradient Boosting Machine

TODO

### A collection giving a gentle Introduction to R

If you are new to R, this example is a great introduction to the language and
its libraries. Here are the topics that are covered:

1. Getting Started
1. A First look at R
1. Data structures
1. Functions
1. More functions
1. Data manipulation
1. Plots
1. Basic statistics
1. Data exploration
1. Clustering
1. Classification
1. Working with SQLite

