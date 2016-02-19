---
layout: default
---

# Welcome to R Tools for Visual Studio Preview

![](./media/RTVS-screenshot.png)

## Key features in Version 0.1

* Full Visual Studio editing experience, including tabbed windows, syntax highlighting, and more!
* Debugging support, with breakpoints, stepping, watch windows, call stacks and more!
* Interactive R: work with the R console directly from within Visual Studio
* IntelliSense (also known as command completion) available in both the editor and the Interactive R window
* History window: see all of the commands that you have entered in a scrollable window
* Integrated plotting support: see all of your R plots in a Visual Studio tool window
* Integrated Help: use ? and ?? to view R documentation within Visual Studio
* Variable Explorer that lets you drill into your R data structures and examine their values
* Table Viewer: quickly see values in your data frames
* Simplify your Visual Studio environment for Data Science by bringing the most commonly used commands to the forefront

<iframe width="560" height="315" src="https://www.youtube.com/embed/VEOhaP4x7LE" frameborder="0" allowfullscreen></iframe>

## Documentation

* [First steps](installation.html)
* [How to start a new project](start-project.html)
* [Editing](editing.html)
* [History window](history.html)
* [R Interactive Window](interactive-repl.html)
* [IntelliSense](intellisense.html)
* [Variable Explorer](variable-explorer.html)
* [Plotting](plotting.html)
* [Debugging](debugging.html)
* [Help](help.html)

## FAQ

**Q. Is RTVS going to be free?**

A. Yes! RTVS when combined with Visual Studio Community Edition is a complete
and perpetually free IDE. RTVS itself will also be Open Source. We will
release the code on Github when it is ready. Parts of the source code that link
to R are already available under GPLv2 at the [R-Host repository on
Github](https://github.com/microsoft/R-Host).

**Q. What versions of Visual Studio does RTVS run on?**

A. Visual Studio 2015 Update 1. Community, Pro, and Enterprise Editions.

**Q. Does RTVS work with Visual Studio Express editions?**

A. No.

**Q. What R interpreters does RTVS work with?**

A. CRAN R, Microsoft R Open, and Microsoft R Server.

**Q. Where can I download these interpreters?**

A. See the [installation](installation.html) instructions.

**Q. Since RTVS is in VS, does it mean that R can be easily used with C#, C++ and
other Microsoft languages?**

A. No. RTVS is a tool for developing R code, and uses the standard native R
interpreters. We do not have any support currently for interop between R and
other languages.

**Q. Feature X is missing, but RStudio has it!**

A. RStudio is a fantastic and mature IDE for R that's been under development for
years. RTVS is a long way from RStudio, because we've only been developing it
for months. We hope to have all the critical features that you need to be
successful in the coming year. Please help us prioritize the TODO list by taking
the [RTVS survey](https://www.surveymonkey.com/r/RTVS1).

**Q. Will RTVS work on MacOS / Linux?**

A. No. RTVS is built on top of Visual Studio, which is a Windows-only
implementation. However, we are looking at porting RTVS to run on top of Visual
Studio Code, which is the new cross-platform IDE from Microsoft.

**Q. Can I contribute to RTVS?**

A. Absolutely! We will release the source in the near future, and PRs are very
welcome. For now, the most important contribution is feedback and bug reports.

**Q. I want to try out the R markdown support and knitr. What do I need to install
to get it to work?**

A. You need to install [pandoc](http://pandoc.org/installing.html). You will
also need to install the knitr and rmarkdown packages.

{% highlight R %}
install.packages("knitr")
install.packages("rmarkdown")
{% endhighlight %}

**Q. I want to save my plots as PDFs. What software do I need for that?**

A. See above.

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

## Feedback

We're looking for your feedback! Please use the R Tools / Feedback menu to send
us smiles and frowns!

## Contributing

If you're interested in contributing to the docs or samples, feel free to clone
the repo and submit a PR. More instructions can be found in our [contribution
guide](contributing-docs.html).
