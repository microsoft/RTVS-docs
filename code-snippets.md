---
layout: default
---

# Code Snippets

Perhaps the biggest everyday productivity boost that you'll get in Preview 0.3
is Code Snippets. These are pieces of code that expand when you type the code
snippet (which appears in the IntelliSense list) and press TAB. 

Some simple examples:

- type =TAB and VS expands to the <- assignment operator.
- type >TAB and VS expands to the %>% pipe operator

If you want to examine the Code Snippets in Visual Studio, use the Tools/Code
Snippets Manager menu to bring up the UI. Select R from the list of languages in
the drop-down to see all of the snippets that we've defined for R.

![](media/code_snippets_box_plot.png)

Snippets can be much more than just completion of characters. They can save you
from having to remember the names of parameters in complex function calls.
Here's an example of a snippet for reading a CSV file via the `read.csv`
function:

![](media/code_snippet_expansion.gif)

You can create your own Code Snippets as well; this is well-documented in [this
MSDN article](https://msdn.microsoft.com/en-us/library/ms165394.aspx).

A code snippet is just an XML file; here's the Code Snippet for the pipe
operator:

![](media/code_snippet_example.png)

