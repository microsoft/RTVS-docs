---
layout: default
---

# R Tools for Visual Studio Sample Projects

This collection of samples will get you started on R, [Microsoft R Server](https://www.microsoft.com/en-us/server-cloud/products/r-server/) and R Tools for Visual Studio. To get them:

1. Download [this zip file](https://github.com/Microsoft/RTVS-docs/archive/master.zip).
2. Unzip.
3. Open `examples/Examples.sln`.

`README` files will help you navigate the samples.

At the top level, ** A First Look at R ** gives a gentle introduction for newcomers to R. ** MRS and Machine Learning ** gives examples of how to use R and Microsoft R Server for machine learning.


## What's special about Microsoft R Open and Microsoft R Server?

[Microsoft R Open](https://mran.revolutionanalytics.com/open/), Microsoft's distribution of R, is different from [CRAN R](https://cran.r-project.org/) in two important ways:

1. [Better computation performance](https://mran.revolutionanalytics.com/rro/#intelmkl1) when used with the [Intel Math Kernel Libraries](https://software.intel.com/en-us/intel-mkl). These are available as a free download from Microsoft for use with Microsoft R Open.

1. [Reproducible R Toolkit](https://mran.revolutionanalytics.com/rro/#reproducibility), which ensures that the libraries you used to build your R program are always available to others that want to reproduce your work.


[Microsoft R Server](https://www.microsoft.com/en-us/server-cloud/products/r-server/) is an extension of R that allows you to handle more data and handle it faster. It gives R two powerful capabilities:

1. Larger data sets. MRS can process out-of-memory data from a variety of sources including Hadoop clusters, databases and data warehouses. You never have to be limited by your RAM again.

1. Parallel, multi-core processing. MRS can efficiently distribute computation across all the computational resources it has available. On your personal workstation or a remote cluster, MRS will get an answer faster.


![benchmark](./media/speed_comparison.png)

![rxGlm benchmark](./media/samples/Introduction_to_R_Server/rxGLM_benchmark.PNG)


For a technical comparison of R with MRO and MRS, check out [Lixun Zhang's
detailed discussion](http://htmlpreview.github.io/?https://github.com/lixzhang/R-MRO-MRS/blob/master/Introduction_to_MRO_and_MRS.html) on the topic. 

## Samples highlights

* R MRO MRS Comparison
	This six-part comparison shows where the commands, syntax, constructs and performance of R, Microsoft R Open and Microsoft R Server are similar, and where they differ.

* Machine learning
	Samples learning to predict flight delays, housing prices and bike rentals show how to solve real world problems with both R and MRS. They also show you how to use several popular machine learning models and how to deploy them as an Azure Web Service using an [Azure Machine Learning](https://azure.microsoft.com/en-us/services/machine-learning/) workspace.

* Benchmarks
    Microsoft R Open includes the Intel Math Kernel Library (MKL) for fast, parallel linear algebra computations. This example runs a number of compute-intensive benchmarks to show the performance gains that are possible through the use of MKL. This sample produces a box plot showing the impact of running the same computation on multiple cores:

    ![](./media/sample_mro_benchmark_plot.PNG)



