---
layout: default
---

## Welcome to R Tools for Visual Studio Preview!

![](./media/RTVS-screenshot.png)

## About this release

**THANK YOU** for checking out this early version of R Tools for Visual Studio
(RTVS).  We've decided to make it available early so that we'll have more time
to address your feedback.  As such, there are bugs and missing features, so
please beware!  This release is meant for evaluation purposes only and not for
production use.

If you **already** have VS2015 with Update 1 installed and R installed, you can
download RTVS from the link below - but we highly recommend following the
[Installation guide](installation.html):

* [Download R Tools for Visual Studio](https://aka.ms/rtvs-current)

## Key features in Version 0.3

For an overview of what is new in 0.3, please see [our What's New in 0.3
page](new_for_03.html).


### Completely new features

* [Package Manager](package-manager.html) - Graphical package manager
* [Code Snippets](code-snippets.html) - Insert code snippets with simple
    keystrokes to write code faster
* [Code Navigation](code-navigation.html) - Quickly navigate to different
    functions within your project

### Existing improved features

* [IntelliSense](intellisense.html) - IntelliSense now works for user-defined
    functions within the same file
* [Debugging](debugging.html) - Debugger tooltips 
* [Variable Explorer](variable-explorer.html) - Excel integration and support
    for browsing variables in different scopes

## A quick video overview 

<iframe width="560" height="315" align="middle" src="https://www.youtube.com/embed/KPS0ytrt9SA" frameborder="0" allowfullscreen></iframe>

<br>

## Installation and first steps

The pre-requisites for RTVS are: 

* Visual Studio 2015 Community, Professional or Enterprise
* Visual Studio 2015 Update 1 or Update 2
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

**Q. Should I use RTVS in production?**

A. No. This is the second public preview. As such, there are bugs and missing
features which will be addressed in the next few months. This release is only
recommended for evaluation purposes and usage in production is strongly advised
against.

**Q. Is RTVS going to be free?**

A. Yes! RTVS when combined with free Visual Studio Community Edition is a complete
and perpetually free IDE. Please make sure that you [read the software license terms 
to see if you qualify for using the free edition of Visual Studio Community Edition](https://www.visualstudio.com/support/legal/mt171547).

**Q. Is RTVS Open Source?**

A. Yes! The source code for RTVS is [available on
Github](https://github.com/microsoft/RTVS) and is released under the terms of
the MIT license. There is a second component of RTVS, called RHost, which links
to the R Interpreter binaries. Its source code is also [available on
Github](https://github.com/microsoft/R-Host) and is released under the terms of
the GNU Public License V2.

**Q. What versions of Visual Studio does RTVS run on?**

A. Visual Studio 2015 Update 1 and higher. Community, Pro, and Enterprise
Editions.

**Q. Does RTVS work with Visual Studio Express editions?**

A. No.

**Q. What R interpreters does RTVS work with?**

A. CRAN R, Microsoft R Open, and Microsoft R Server.

**Q. Where can I download these interpreters?**

A. See the [installation instructions](installation.html).

**Q. Since RTVS is in VS, does it mean that R can be easily used with C#, C++
and other Microsoft languages?**

A. No. RTVS is a tool for developing R code, and uses the standard native R
interpreters. We do not have any support currently for interop between R and
other languages.

**Q. Feature X is missing, but RStudio has it!**

A. RStudio is a fantastic and mature IDE for R that's been under development for
years. RTVS is a long way from RStudio, because we've only been developing it
since July, 2015. We hope to have all the critical features that you need to be
successful this summer. Please help us prioritize the TODO list by taking
the [RTVS survey](https://www.surveymonkey.com/r/RTVS1).

**Q. Will RTVS work on MacOS / Linux?**

A. No. RTVS is built on top of Visual Studio, which is a Windows-only
implementation. However, we are looking at porting RTVS to run on top of Visual
Studio Code, which is the new cross-platform IDE from Microsoft.

**Q. Can I contribute to RTVS?**

A. Absolutely! The source code lives on
[Github](https://github.com/microsoft/RTVS). Please use our issue tracker to
submit / vote / comment on bugs!

**Q. Does RTVS work with my source control system?**

A. Yes, you can use any source control system that is integrated into Visual
Studio. e.g., TFS, git, SVN, hg etc.

**Q. I don't use a US English locale in Windows or in VS. Will RTVS work?**

A. It should. However, we haven't done extensive testing in non-US English
locales. For the best experience with the Preview bits, please set your local to
English in Visual Studio. You can do so through Tools / Options dialog box,
setting International Settings Language to English. If English is not available
in the drop-down, you'll need to install the [Visual Studio Language
pack](https://www.microsoft.com/en-us/download/details.aspx?id=48157).

![](./media/FAQ-international-settings.png)

**Q. Will RTVS work with 32-bit editions of R?**

A. No. RTVS only supports 64-bit editions of R.

**Q. What are the key missing features of RTVS currently?** 

A. There a number of these. For example:

* Variable Explorer does not allow edit, search, sort.
* Refactoring in the Editor 
* Rendering Shiny apps or `ggviz` plots in a VS window. We currently
    render using the default browser
* Customization options when saving plots as PDF or bitmaps

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
