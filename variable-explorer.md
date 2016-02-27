---
layout: default
---

## Variable Explorer

The Variable Explorer provides a list of all variables at global scope from the REPL. So, if in the REPL you executed:
 
![](./media/RTVS-REPL-variable-explorer-example.png)

The variable explorer will display the following data:

![](./media/RTVS-REPL-variable-explorer-example-result.png)

If you have a more complex R data frame defined in the REPL, you can drill into the data. If you execute these commands:
 
![](./media/RTVS-REPL-variable-explorer-cmds-example.png)

You will see this view in the Variable Explorer:

![](./media/RTVS-REPL-variable-explorer-cmds-example-results.png)
 
Next we click on the chevron to drill into the data:

![](./media/RTVS-REPL-variable-explorer-cmds-example-drill-down.png)

We can drill as deep as the data is nested within the data frame:
 
![](./media/RTVS-REPL-variable-explorer-cmds-example-drill-down2.png)

Since the data for each team is *tabular*, it makes sense to view them in a
table form. If you click on the magnifying glass icon next to the team name, you'll
open up the Data Table Viewer:

![](./media/RTVS-REPL-variable-explorer-table-view.png)
