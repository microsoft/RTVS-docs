---
layout: default
---

# Variable Explorer

The Variable Explorer provides a list of all variables at global scope from the
REPL. So, if in the REPL you executed:
 
![](./media/RTVS-REPL-variable-explorer-example.png)

The variable explorer will display the following data:

![](./media/RTVS-REPL-variable-explorer-example-result.png)

If you have a more complex R data frame defined in the REPL, you can drill into
the data. If you execute these commands:
 
![](./media/RTVS-REPL-variable-explorer-cmds-example.png)

You will see this view in the Variable Explorer:

![](./media/RTVS-REPL-variable-explorer-cmds-example-results.png)
 
Next we click on the chevron to drill into the data:

![](./media/RTVS-REPL-variable-explorer-cmds-example-drill-down.png)

We can drill as deep as the data is nested within the data frame:
 
![](./media/RTVS-REPL-variable-explorer-cmds-example-drill-down2.png)

## Data Table Viewer

Since the data for each team is *tabular*, it makes sense to view them in a
table form. If you click on the magnifying glass icon next to the team name, you'll
open up the Data Table Viewer:

![](./media/RTVS-REPL-variable-explorer-table-view.png)

## Export to Excel

While the data table viewer is a great tool, sometimes you want to be able to
take your data frame and *export* it to Excel. We've made it easy to do that in
this release by adding a small Excel icon to the variable explorer:

![](media/variable_explorer_icon.png)

When you click on it, it will take your data frame and export it to a new Excel
Workbook:

![](media/variable_explorer_excel_view.png)

## Scopes 

We now let you pick different _scopes_ for the variables in the variable
explorer; previously you could only examine variables at global scope. Now, with
package level scope, we give you a view over all of the variables (including
functions, which are just functions bound to variables) defined within a
package:

![](media/variable_explorer_package_contents.png)

When you are debugging, variable explorer also recognizes the current execution
scope (i.e., when you are debugging code within a function). Here, local
variables that you define within that function can now be inspected using
variable explorer. In the picture below, you can see that the current execution
scope is within a function called `renderUI`, and that there are two
local variables defined at the current execution point: `country_data` and
`max_destinations`:

![](media/variable_explorer_view_locals.png)
