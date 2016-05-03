---
layout: default
---

# Use multiple project types in Visual Studio

In Visual Studio, related files are collected into a **Project**, and related
Projects are collected into a **Solution**.  

Here we see a Solution that consists of 5 separate Projects made up of C\++, R,
Python and SQL code.  The user has built a model using R/Azure ML,
Python/scikit-learn, C++ for compute intensive work, SQL for data management,
and finally a Python/bottle project to share results via Azure:

![Help window](./media/polyglot.png)

Solutions provide a convenient place to gather and manage relevant Projects
(which maybe worked on by other team members) in one logical place.

Note that there isn't currently any explicit R <-> C#/C\++ language integration
in place yet.  However there are libraries available that provide bridges
between C#/R and C\++/R.
