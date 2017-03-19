---
layout: default
---

# Working with the R Interactive Window

R Tools for Visual Studio (RTVS) includes interactive windows for each of your
installed environments. Also known as **REPL** (Read/Evaluate/Print Loop)
windows, these allow you to enter R code and see the results immediately. You
can use all modules, syntax and variables, just like in an R script.

## Overview of the REPL

Typing valid R code and pressing **ENTER** at the end of the line will execute
the code on that line.

![Interactive math](./media/RTVS-REPL-interactive-math.png)

All previous input and output in the REPL is read-only and cannot be changed.
You can select output using the mouse and copy to the clipboard using
**CTRL-C**. You can also right-click using the mouse and select copy from the
context menu:

![Copy](./media/RTVS-REPL-copy.png)

You can paste input into the REPL by using **CTRL+V** at an input prompt or by
right-clicking and using the context menu:

![Insert](./media/RTVS-REPL-insert.png)

On a single-line REPL input, pressing **ENTER** anywhere within that line will
execute the code on that line:

![Execute](./media/RTVS-REPL-execute.png)

If you are executing some code in the REPL, and you want to cancel the currently
running code, you can press **ESCAPE**, or click on the **Interrupt R **button
on the toolbar:
 
![Escape](./media/RTVS-REPL-escape.png)

## Workspaces and sessions

While you are executing code during an interactive session in you are building
up context (i.e., global variables, function definitions, library loads etc.).
This context is collectively called a Workspace, and you have the ability to
load and save workspaces. To save a Workspace using a specific filename (the
default is `.RData`), click on the Save Workspace button in the REPL:

![Save workspace](./media/RTVS-REPL-save-workspace.png)

It brings up this dialog where you can choose where to save the Workspace to:
 
![Save workspace dialog](./media/RTVS-REPL-save-workspace-dialog.png)

If you want to reset that context to start over again from a clean slate, you
can do so by clicking on the **Reset** button:
 
![Reset](./media/RTVS-REPL-reset.png)

If you want to re-load a previous Workspace, you can do so using the Load
Workspace button in the REPL toolbar:

![Reload workspace](./media/RTVS-REPL-reload-workspace.png)

This will pop up a dialog that asks you what Workspace file you want to load:

![Reload workspace dialog](./media/RTVS-REPL-reload-workspace-dialog.png)
 
## <a name="repl-history"></a>REPL history

## History

The REPL supports history. Every line that you type and execute using the REPL
is preserved in your history. Consider this example:
 
![](./media/RTVS-REPL-history-example.png)

In this case your history will contain 3 entries: 3 + 3, 4 + 4, and 5 + 5.

The REPL supports navigating through history. If you have an empty input and you
press the **UP ARROW** key, we will put the first entry in your history into the
current input line:
 
![](./media/RTVS-REPL-history-up-arrow.png)

If you press **UP ARROW** repeatedly, you will navigate backwards through your
REPL history until you reach the first element in your history. Pressing UP
ARROW once you have reached the "top" of your history has no effect:
 
![](./media/RTVS-REPL-history-up-arrow-repeat.png)

Pressing DOWN ARROW repeatedly will navigate you forwards through your history
until you reach the most recent element in your history. Pressing DOWN ARROW
once you have reached the "bottom" of your history has no effect:
 
![](./media/RTVS-REPL-history-down-arrow.png)

If you start typing something on the current line, and then press UP ARROW, the
current line will be added to your history. 

![](./media/RTVS-REPL-history-up-arrow-current-line.png)

Now press UP ARROW: 

![](./media/RTVS-REPL-history-up-arrow-current-line-press.png)

Now press DOWN ARROW:

![](./media/RTVS-REPL-history-down-arrow-current-line-press.png)
 
Note that what you originally typed is preserved in this case, and that we have
positioned the cursor at the start of the line.
 
## History and multi-line code blocks

The REPL supports multi-line code blocks. So if you define a function and press {,
we will both auto-type } for you as well as enable smart multi-line behavior. 
 
![](./media/RTVS-REPL-history-multilines.png)

This means that if you press the **ENTER** key while your cursor is positioned
within the curly brace scope, we will enter multi-line mode and place the cursor
at the correctly indented position:
 
![](./media/RTVS-REPL-history-multiline-behavior.png)

In multi-line mode, the **ENTER** key will execute the multi-line block only
when it is positioned at the very end of the multi-line block:

![](./media/RTVS-REPL-history-multiline-enter-behavior.png)

If you want to execute the multi-line block when your cursor is not at the very
end of the multi-line block, you can press **CTRL-ENTER** from anywhere within
the multi-line block.

The multi-line REPL has unique behavior with respect to history. If you are
within a multi-line block, the cursor arrow keys (**LEFT**, **RIGHT**, **UP**,
and **DOWN**) will navigate throughout the code block, just like it were an
editor window. However, if you are on the first line of a multi-line code block
and press the **UP ARROW** key, the REPL will replace the current multi-line
code block with the most recent item from history. Below you can see that the
caret is positioned on the first line of the multi-line block. 
 
![](./media/RTVS-REPL-history-multiline-history-behavior.png)

When I press **CURSOR UP** from this point, you will see that the multi-line
block was replaced by "5 + 5", the most recent item from my history:
 
![](./media/RTVS-REPL-history-multiline-up.png)

If I press **CURSOR DOWN** at this point, my original input will be restored:
 
![](./media/RTVS-REPL-history-multiline-down.png)

Note that the cursor is positioned at the start of the first line, which makes
it easy to reverse direction and go backwards in history with a single **CURSOR
UP** keypress.

Now consider a case where the last two most recent entries in history are
multi-line inputs:
 
![](./media/RTVS-REPL-history-multiline-inputs.png)

If you press **CURSOR UP** once, you will see that the current input line now
contains the `sub()` function definition:

![](./media/RTVS-REPL-history-multiline-inputs.png)
 
Note that the cursor is positioned at the very end of the sub function
definition. This lets a user immediately hit ENTER to execute the multi-line
code block. This was done to optimize for the case of users repeatedly
re-executing the same command by pressing **CURSOR UP** + **ENTER** repeatedly.

![](./media/RTVS-REPL-history-multiline-inputs-repeat.png)

If you press **UP ARROW** two more times, you will wind up on the first line of
the `sub()` function definition multi-line code block. If you press **UP ARROW**
one more time, you will see the `sub()` function multi-line code block replaced
by the `add()` function multi-line code block. As was the case before, notice
how the cursor is placed at the very end of the `add()` function multi-line code
block. This makes it convenient for the user to immediately hit **ENTER** to
execute that multi-line code block.

![](./media/RTVS-REPL-history-multiline-execute.png)
 
Now, if you press **DOWN ARROW**, you will see that the cursor is on the first
line of the next most recent item in history. This was done so that you can
immediately go backwards in history by pressing CURSOR UP. Note that the
position of the cursor will not let you go down and immediately execute the
multi-line code block by pressing **ENTER** in this case. You can execute by
either moving to the last character in the multi-line code block and pressing
**ENTER**, or by pressing **CTRL-ENTER** from anywhere in the multi-line code
block.
 
![](./media/RTVS-REPL-history-multiline-execute-down.png)

At any point in time, if you want to force navigation through history and you
don't want to navigate to the top / bottom of a multi-line code block
(especially annoying with large multi-line code blocks) first, press **ALT+UP
ARROW** or **ALT+DOWN ARROW**. Notice that the REPL window has toolbar buttons
for these as well as tool-tips that will help make this feature more
discoverable:

![](./media/RTVS-REPL-history-multiline-navigation.png)

## Working Directory

It's pretty common to switch your working directory while working in an
interactive R session. We've now made it even easier to switch your working
directory by adding some additional commands:

1. You can switch the current working directory to the directory that contains
   the current file that you're editing. CTRL+SHIFT+E runs this command.

1. You can switch the current working directory to the directory that contains
   the root of the RTVS project. CTRL+SHIFT+P runs this command.

There are two new toolbar icons within the R Interactive Window that are also
run these commands for folks who are like to use the mouse:

![](media/04_working_directory.png)

Code snippets now work in both the editor and the R Interactive Window. Below,
I'm typing = and then pressing TAB to perform the completion.

![](media/04_repl_snippets.gif)