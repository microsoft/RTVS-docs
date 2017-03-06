---
layout: default
---

# Code Snippets

There are common pieces of code that you type every day such as create a plot or
read a CSV file. To help make you more productive in your day-to-day work, we
have added a number of `Code Snippets` to Visual Studio. A `Code Snippet` makes
it easier for you to enter repeating code patterns. To insert one of those code
patterns into your editor, you need:

1. Type the abbreviated name of the Code Snippet (IntelliSense is available)
1. Press the trigger key, TAB, to insert the code snippet

Some simple examples:

- type =TAB and VS expands to the <- assignment operator.
- type >TAB and VS expands to the %>% pipe operator

Snippets can be much more than just completion of characters. They can save you
from having to remember the names of parameters in complex function calls.
Here's an example of a snippet for reading a CSV file via the `read.csv`
function:

![](media/code_snippet_expansion.gif)

The characters that you type will be `readc`. As you type, you can see that it
shows up on your IntelliSense completions list as well as you type. Once it is
selected in the IntelliSense dropdown, you can complete the selection by
pressing TAB. At this point, the string `readc` will be immediately to the left
of your cursor. Pressing TAB again will cause the expansion of the snippet. This
explains why sometimes you think of snippet expansion as being "type the snippet
and press TAB twice". In most cases, the first TAB completes the selection in
IntelliSense, and the second TAB triggers the snippet expansion.

## Create your own Code Snippets

If you want to examine the Code Snippets in Visual Studio, use the Tools -> Code
Snippets Manager command to bring up the UI. Select R from the list of languages in
the drop-down to see all of the snippets that we've defined for R.

![](media/code_snippets_box_plot.png)

You can create your own Code Snippets as well; this is well-documented in [this
MSDN article](https://msdn.microsoft.com/en-us/library/ms165394.aspx).

Note that a code snippet is just an XML file; here's the Code Snippet for the pipe
operator:

![](media/code_snippet_example.png)
