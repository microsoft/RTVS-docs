---
layout: default
---

## Welcome to R Tools for Visual Studio Preview!

![](./media/installer_screenshot.png)

## About this release

This is our final release on the road to 1.0! Please try this release in all of
your data science scenarios and [send us your
feedback](https://github.com/Microsoft/RTVS/issues).

If you **already** have Visual Studio 2015 with Update 3 (or higher) and R
installed, you can download RTVS from the link below - but we highly recommend
following the [Installation guide](installation.html):

* [Download R Tools for Visual Studio](https://aka.ms/rtvs-current)

## Key features in Version 1.0

The key new feature in RTVS 1.0 is our [Remote Execution](remote-execution.html)
feature. You can [configure a secure server](setup-remote.html) that your data
scientists can share. This server lets you:

* Make more powerful computing resources (CPU, GPU, memory) available to your
  data scientsts.
* Lock down sensitive data to a secure, IT-managed server. Data scientists must
  bring their code to the data, not the other way around.

### Table of contents for the documentation

* [Variable Explorer](variable-explorer.html)
* [Editor](editing.html)
* [History window](history.html)
* [Help](help.html)
* [Plotting](plotting.html)
* [SQL tooling](sqlserver.html)
* [R Interactive Window](interactive-repl.html)
* [IntelliSense](intellisense.html)
* [Debugging](debugging.html)
* [R Markdown](rmarkdown.html)
* [Git](git.html)
* [Extensions](extensions.html)
* [Polyglot IDE](polyglot.html)
* [Remote Execution](remote-execution.html)

## Video feature walk-throughs

Here's the most recent walk-through video for RTVS 0.4:

<iframe width="560" height="315" align="middle" src="https://www.youtube.com/embed/k1_6XLyhHbo" frameborder="0" allowfullscreen></iframe>

Here's the video for 0.3:

<iframe width="560" height="315" align="middle" src="https://www.youtube.com/embed/KPS0ytrt9SA" frameborder="0" allowfullscreen></iframe>

<br>

## Installation and first steps

The pre-requisites for RTVS are: 

* Visual Studio 2015 Community, Professional or Enterprise
* Visual Studio 2015 Update 3
* An R interpreter: CRAN-R or Microsoft R Open

Please check out the installation steps, *especially* if you are new to Visual
Studio

* [RTVS Installation](installation.html) 

Once installed, create a project and code away!

* [How to start a new project in RTVS](start-project.html)

## Feedback, bugs, etc.

Please file bugs and feature requests directly on:

* [RTVS on Github](https://github.com/Microsoft/RTVS)

To send us bug repros (which are highly appreciated) try the built in
Smile/Frown feature:

* Go to: R Tools / Send a frown (or smile)

This will collect logs, start your mail client and attach the log file.  You can
then examine the contents and click Send. The logs are zipped into
%TEMP%/RTVSlogs.zip in case you want to send it yourself.

Finally you can send direct feedback to the team at
[rtvsuserfeedback@microsoft.com](mailto:rtvsuserfeedback@microsoft.com).

<br>
<hr>
<br>

## FAQ

**Q. Is RTVS going to be free?**

A. Yes! RTVS when combined with free Visual Studio Community Edition is a
complete and perpetually free IDE. Please make sure that you [read the software
license terms to see if you qualify for using the free edition of Visual Studio
Community Edition](https://www.visualstudio.com/support/legal/mt171547).

**Q. Is RTVS Open Source?**

A. Yes! The source code for RTVS is [available on
Github](https://github.com/microsoft/RTVS) and is released under the terms of
the MIT license. There is a second component of RTVS, called RHost, which links
to the R Interpreter binaries. Its source code is also [available on
Github](https://github.com/microsoft/R-Host) and is released under the terms of
the GNU Public License V2.

**Q. What versions of Visual Studio does RTVS run on?**

A. Visual Studio 2015 Update 3 and higher. Community, Pro, and Enterprise
Editions.

**Q. Does RTVS work with Visual Studio Express editions?**

A. No.

**Q. What R interpreters does RTVS work with?**

A. [CRAN R](https://cran.r-project.org/), [Microsoft R Client and Microsoft R
Server](https://msdn.microsoft.com/en-us/microsoft-r/)

**Q. Where can I download these interpreters?**

A. See the [installation instructions](installation.html).

**Q. Since RTVS is in VS, does it mean that R can be easily used with C#, C++
and other Microsoft languages?**

A. No. RTVS is a tool for developing R code, and uses the standard native R
interpreters. We do not have any support currently for interop between R and
other languages.

**Q. Feature X is missing, but RStudio has it!**

A. RStudio is a fantastic and mature IDE for R that's been under development for
many years. We hope to have all the critical features that you need to be
successful. Please help us prioritize the TODO list by taking the [RTVS
survey](https://www.surveymonkey.com/r/RTVS1).

**Q. Will RTVS work on MacOS / Linux?**

A. No. RTVS is built on top of Visual Studio, which is a Windows-only
implementation. However, we are looking at building a new set of tools that run
on top of [Visual Studio Code](https://code.visualstudio.com/), which is the
wildly popular cross-platform editor from Microsoft.

**Q. Can I contribute to RTVS?**

A. Absolutely! The source code lives on
[Github](https://github.com/microsoft/RTVS). Please use our issue tracker to
submit / vote / comment on bugs!

**Q. Does RTVS work with my source control system?**

A. Yes, you can use any source control system that is integrated into Visual
Studio. e.g., TFS, git, SVN, hg etc.

**Q. I don't use a US English locale in Windows or in VS. Will RTVS work?**

A. The 1.0 release of RTVS will be English-only. The 1.1 release will be
localized to the same set of languages that Visual Studio itself is. In the
meantime, we recommend using the English language pack for Visual Studio. If
English is not available in the drop-down, you'll need to install the [Visual
Studio Language
pack](https://www.microsoft.com/en-us/download/details.aspx?id=48157).

![](./media/FAQ-international-settings.png)

**Q. Will RTVS work with 32-bit editions of R?**

A. No. RTVS only supports 64-bit editions of R.

**Q. What are the key missing features of RTVS currently?** 

A. There a number of these. For example:

* Refactoring in the Editor 
* Rendering Shiny apps or `ggviz` plots in a VS window. We currently
    render using the default browser

We'll be addressing these in the near future.

**Q. I really like my current Visual Studio settings, but I want to try out the
new Data Science settings. What should I do?**

A. You can always save your current Visual Studio settings through Tools ->
Import and Export Settings... command. You can also use this command to restore
one of the default Visual Studio settings (e.g., C++ or General).

**Q. What is the recommended `.gitignore` settings for an RTVS project?**

A. Github maintains a master repository of recommended `.gitignore` files. You
can see it here: [R
.gitignore](https://github.com/github/gitignore/blob/master/R.gitignore)

**Q. Can I store my Visual Studio project on a network share?**

A. No. This is not a supported scenario for Visual Studio.

## Feedback

We're looking for your feedback! Please use the R Tools / Feedback menu to send
us smiles and frowns!

## Contributing

If you're interested in contributing to the docs or samples, feel free to clone
the repository and submit a pull request. More instructions can be found in our
[contribution guide](contributing-docs.html).
