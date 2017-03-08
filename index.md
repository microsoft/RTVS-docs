---
layout: default
---

## Welcome to R Tools for Visual Studio Preview!

![](./media/installer_screenshot.png)

## Installation and Getting Started

The pre-requisites for RTVS are: 

* Visual Studio 2015 Community, Professional or Enterprise
* Visual Studio 2015 Update 3
* An R interpreter: CRAN-R or Microsoft R Open
* Note that the Visual Studio 2017 release of RTVS is not quite ready yet, but
  will ship soon.

Please check out the installation steps, *especially* if you are new to Visual
Studio

* [RTVS Installation](installation.html) 

Once installed, create a project and code away!

* [How to start a new project in RTVS](start-project.html)

## About this release

This is our final release on the road to 1.0! Please try this release in all of
your data science scenarios and [send us your
feedback](https://github.com/Microsoft/RTVS/issues).

If you **already** have Visual Studio 2015 with Update 3 (or higher) and R
installed, you can download RTVS from the link below - but we highly recommend
following the [Installation guide](installation.html):

* [Download R Tools for Visual Studio](https://aka.ms/rtvs-current)

## Key features in Version 1.0

TODO: write a comprehensive summary of the feature set of RTVS. Highlights:

feature. You can [configure a secure server](setup-remote.html) that your data
scientists can share. This server lets you:

* Make more powerful computing resources (CPU, GPU, memory) available to your
  data scientists.
* Lock down sensitive data to a secure, IT-managed server. Data scientists must
  bring their code to the data, not the other way around.

### Table of contents for the documentation

* [Variable Explorer](variable-explorer.html)
* [Editor](editing.html)
* [Code Navigation](code-navigation.html)
* [Code Snippets](code-snippets.html)
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

TODO: update videos

Here's the most recent walk-through video for RTVS 0.4:

<iframe width="560" height="315" align="middle" src="https://www.youtube.com/embed/k1_6XLyhHbo" frameborder="0" allowfullscreen></iframe>

Here's the video for 0.3:

<iframe width="560" height="315" align="middle" src="https://www.youtube.com/embed/KPS0ytrt9SA" frameborder="0" allowfullscreen></iframe>

<br>

## Send us your feedback!

We have three different ways you can send feedback to the team:

1. **Via Github**: This is the preferred way to send us feedback. You can use
   [this link](https://github.com/Microsoft/RTVS/issues), or the built-in
   shortcut in the RTools -> Feedback menu.

1. **Send a Smile / Frown**: This is a quick way to send feedback **and** attach
RTVS log files to assist in the diagnosis of your issue. You can find this
command under the R Tools -> Feedback menu. This command will collect logs,
start your mail client and attach the log file. You have the opportunity to
examine the contents of those files before you click Send. The logs are written
into `%TEMP%/RTVSlogs.zip` in case you want to send it yourself.

1. **Via email**: You can send direct feedback to the team at
[rtvsuserfeedback@microsoft.com](mailto:rtvsuserfeedback@microsoft.com).

## Frequently Asked Questions

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
Editions. Visual Studio 2017 support will be released shortly.

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
implementation. However, we are investigating building a new set of tools based
on [Visual Studio Code](https://code.visualstudio.com/), the wildly popular
cross-platform editor from Microsoft.

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

**Q. I really like my current Visual Studio settings, but I want to try out the
new Data Science settings. What should I do?**

A. You can always save your current Visual Studio settings through Tools ->
Import and Export Settings... command. You can also use this command to restore
one of the default Visual Studio settings (e.g., C++ or General).

**Q. What are the recommended `.gitignore` settings for an RTVS project?**

A. Github maintains a master repository of recommended `.gitignore` files. You
can see it here: [R
.gitignore](https://github.com/github/gitignore/blob/master/R.gitignore)

**Q. Can I store my Visual Studio project on a network share?**

A. No. This is not a supported scenario for Visual Studio.

## Contributing to the docs and samples

If you're interested in contributing to the docs or samples, feel free to clone
the repository and submit a pull request. More instructions can be found in our
[contribution guide](contributing-docs.html).
