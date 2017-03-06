---
layout: default
---

# Code Navigation

When you are writing code, you often want to quickly look up the definition of a
function that you are calling. In RTVS, we give you two different ways of doing
this. The first is the straightforward `Go To Definition` command, that you can
invoke one of two ways:

1. Right click on the function that you want to navigate and select the `Go To
   Definition` command from the popup menu. 
1. Place your cursor on the function name and press F12

This command will open up a new editor window containing the source code for the
function, and with the cursor conveniently positioned at the start of the
function definition.

The second is the `Peek Definition` command, which inserts a read-only
scrollable region containing the source code of the function below the function
call, as you can see from the animated GIF below:

![](media/peek_definition.gif)

You can run the `Peek Definition` command one of two ways:

1. Right click on the function that you want to navigate and select the `Peek
   Definition` command from the popup menu. 
1. Place your cursor on the function name and press ALT+F12
