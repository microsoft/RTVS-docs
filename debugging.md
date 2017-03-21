---
layout: default
---

# Debugging with R Tools for Visual Studio

## Starting the debugger

There are two different ways to run code under the debugger: **launching** and
**attaching**.

To **launch** code under the debugger, you must first tell Visual Studio what
script to launch when you press F5. If you have created a new project using
Visual Studio, the file **Script.R**, which was automatically created for you,
is predefined as the startup script. If you want to launch a different script,
all you need to do is right-click on a script in Solution Explorer and run the
`Set As StartUp R Script` command:

![](./media/debugger-set-as-startup-script.png)

You'll want to 


## Attaching the debugger

If you're an experienced Visual Studio user, you'll find that the debugging
experience is a bit different from what you may be used to. For example, if
you're writing a C# console application, you're used to just pressing **F5**
to launch your console application under control of the debugger.

In the R World, the experience is a bit different. (See note [1] below.)

First, you must attach the debugger to the R Runtime. You can do this one of two
different ways:

1. Use the R Tools menu - there is an Attach Debugger command under the Session
   menu:

  ![](./media/RTVS-Debugging-attach-debugger.png)

In your everyday work you should use the toolbar in R Interactive, as it saves
you a number of mouse clicks / keystrokes:

  ![](./media/RTVS-Debugging-r-toolbar.png)

## Set breakpoints

Once you've attached the debugger to R, you'll need to set breakpoints and tell
R the code that you want to debug. The latter is referred to as *sourcing* your
file, which tells the R interpreter to run the code inside the file. Since
you've attached a debugger to the R process, execution will stop at the first
appropriate breakpoint.

For example, if the code that you want to debug is at global scope (i.e., not
within a function) in a file called server.R, you would:

1. Attach the debugger to R (you'll notice that Visual Studio will change your
   window layout to the debugger window layout).
2. Set a breakpoint in the file in the example below, this is on line 8.
3. Source the file you can do this via R Tools/Session/Source R Script command,
   or by typing **CTRL+R**, **CTRL+S** with the input focus set to the editor.
   (See note [1] below.)

  ![](./media/RTVS-Debugging-set-breakpoint.png)

All standard Visual Studio debugger commands work, with a few known limitations.
You can:

* Set, Delete, and Deactivate Breakpoints
* Step Over (**F10**) and Step Into (**F11**) the current line
* Continue Execution (**F5**)
* Inspect local variables using the Locals Window
* Inspect arbitrary expressions (that are in scope) using Watch Windows
* Stop Debugging (**SHIFT-F5**)

**Note**: we haven't implemented support for Step Out (**SHIFT+F11**) in the preview
release.

After each debugger command, you'll also see that you are stopped at the
Environment Browser prompt in the R Interactive Window.  From there, you can
also issue Environment Browser commands (e.g., n for next command, or c to
continue execution). 

## Debugger Tooltips

Debugger tooltips let you hover over a variable that you want to inspect, and
then drill down into the objects within that variable. This lets you inspect
arbitrary variables in-place while stopped in the debugger without having to
resort to using other windows like the locals window.

![](media/debugger_tooltips.gif)
