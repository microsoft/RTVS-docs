---
layout: default
---

# Help in R Tools for Visual Studio

The help window pops up within Visual Studio as a tool window. You can get help for a specific topic by title using the `?` command in R:

> `?mtcars`

![Help window](./media/RTVS-Help-window.png)

All standard Visual Studio tool window behavior is available to the **R Help** window.

You can search help using the ?? command in R. Note that you have to quote the search term if it includes spaces.

> `??"Motor Trend"`

![Help search](./media/RTVS-Help-search.png)

You can right-click on a function in the editor or the REPL window

![Help right click](./media/RTVS-Help-right-click.png)
 
Pressing **F1** during an auto-complete operation will send the sub-string used for the auto-complete to the R search engine to return a set of pages that match that sub-string search:

![Help auto-complete](./media/RTVS-Help-auto-complete.png)

To bring up results in your browser:

![Help auto-complete results](./media/RTVS-Help-auto-complete-results.png
)
 
You've always had the option of running the help system inside of a Visual
Studio tool window, or by launching the help in the default browser for your
computer. If you are using the tool window option (which is the default), you
now have the ability to type search terms into a separate search input field:

![](media/help-search.png)

Lots of us run into problems writing our code and turn to the Internet for help.
We've streamlined this a bit further by incorporating keyword search directly
into RTVS. For example, if you were trying to figure out how to use the dplyr
`filter` function in the following code, all you need to do is place your caret
on the filter function call, and press `F1`.

![](media/04_f1.png)

This will bring up search results in a separate tool window. 

![](media/04_search_results.png)

By default we append "R" to the end of your search term, and scope the search to
Stack Overflow, but you can configure it to search with an arbitrary search
clause in the Options dialog for RTVS:

![](media/04_f1_options.png)