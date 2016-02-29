---
layout: default
---

# Plotting

We have support for generating R plots as part of the interactive programming
experience.  Here's a command that generates a simple linear XY plot:

`> plot(1:100)`

It creates a new Visual Studio **R Plot** window that contains the plot figure:

![Linear plot](./media/RTVS-plotting-1to100.png)
 
Since the plot window is a Visual Studio tool window, it supports all of the
standard tool window operations such as tearing off the window into its own top
level window:

![Tear off window](./media/RTVS-plotting-tear-off-window.png)
 
Docking it in various parts of the IDE:

![Doc window](./media/RTVS-plotting-dock-window.png)
 
The plot window will resize the contained plot as the window is resized:

![Resize window](./media/RTVS-plotting-resize-window.png)
