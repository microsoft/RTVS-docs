## Workspaces

Workspaces is a feature in RTVS that lets you control _where_ your R code runs. The Workspaces tool window lets you choose between two types of places where your code can run: Local and Remote.

### Local Workspaces

Local workspaces are the set of all R interpreters that you have installed locally on your computer. Local workspaces can be auto-detected by RTVS when you launch Visual Studio, or you can add your own local workspaces manually.

RTVS will do its best to auto-detect all of the versions R that you have installed, and does so by looking through the registry when Visual Studio starts up. RTVS looks under this registry key to find locally installed R interpreters:

`HKEY_LOCAL_MACHINE\Software\R-Core\`

It is important to understand that this check is only done at Visual Studio startup; if you install a new R interpreter while Visual Studio is running, you will need to restart Visual Studio to detect your newly installed R interpreter.

In the event that you installed R through some non-standard way (i.e., by not running an installer), you can manually create a new R Workspace by clicking on the Add button in the Workspaces window. Enter a name for your new Workspace, and the path to the R root directory (i.e., the directory that contains the `bin` directory where your interpreter is located), and any optional command line parameters that you would like to pass to your R interpreter when RTVS starts it up.

If you want to change an existing Workspace entry, you can always click on the wheel icon next to the Workspace, and change its name, the path (or URI in the case of remote Workspaces), and its command line parameters.

### Remote Workspaces

