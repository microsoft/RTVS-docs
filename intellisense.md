---
layout: default
---

# IntelliSense

IntelliSense is a feature that interactively provides hints about available
commands, functions, members, and snippets as you type. It is available in both
the editor and the Interactive Window. 

## Triggering and controlling IntelliSense

Typing will trigger IntelliSense as you are typing. Note that we have both the
name of the function in the IntelliSense drop-down, as well a brief summary of
what the function does. Note that matches are case-sensitive.

![](./media/RTVS-REPL-auto-complete-menu.png)

IntelliSense suggestions are also available for members of R objects:
 
![](./media/RTVS-REPL-auto-complete-r-objects.png)
 
To accept the current highlighted suggestion while typing, press the **TAB** key:

![](./media/RTVS-REPL-auto-complete-save.png) 

To dismiss the IntelliSense suggestions while typing, press the **ESC**.

To manually activate IntelliSense suggestions while typing (i.e., you
dismissed the drop-down), press **CTRL+SPACE**.

For a function completion, when you type the open parenthesis character `(`, we
will auto-type the close parenthesis character and pop up function parameter
help:

![](./media/RTVS-REPL-auto-complete-functions.png)

You can dismiss the parameter help by pressing **ESC**.

If you have dismissed the parameter help pop-up and you want to get it back,
press **CTRL+SHIFT+Space** to restore it.

If you find the parameter help is obscuring text underneath it, as can be the
case in the file editor, you can press and hold the **CTRL** key to make the
parameter help text translucent.

![](./media/RTVS-REPL-auto-complete-translucent.png)
 
## Scope of IntelliSense

You can get IntelliSense for user-defined functions in the same file:

![](media/intellisense_same_file_functions.png)

IntelliSense also assists in named parameter completion for functions defined in
the same file:

![](media/intellisense_parameter_completion.png)

This also works for variables defined in the file:

![](media/intellisense_variable_completion.png)

IntelliSense behaves subtly differently depending on where you are currently typing:

* **IntelliSense and the Interactive Window**: When typing in the Interactive
Window, IntelliSense will only consider names that are defined in your current R
session. IntelliSense will not look in the files within your project for names
that are defined there.

* **IntelliSense and the Editor**: When typing in an editor window, IntelliSense
will look at **both** the contents of the current file, and any names defined
in your current R session.

## Code Suggestions

When a light bulb appears in the margin, Visual Studio is suggesting that there
is a shortcut available for a commonly used action. If you hover over a line
that contains a `library` statement in the editor, we will display a light bulb
to the left of that line. Clicking on the light bulb will reveal a couple of
options. 

![](media/04_smart_tags.png)
