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

Remote workspaces let you run your R session on a remote computer. Typically, that remote computer is setup by your administrator, or you can [setup a remote Workspace yourself](). 

Remote workspaces are identified by a URI. That URI *must use the HTTPS protocol* to ensure the privacy and the integrity of the code that you are sending to the remote computer, and the results that are being returned from the remote computer. RTVS will refuse to connect to a remote computer that does not support the HTTPS protocol.

Remote workspaces are _not_ auto-detected by RTVS.

### Switching between Workspaces

The active Workspace that RTVS is bound to is clearly indicated by a green icon next to the name of the Workspace. In most cases, when you start RTVS, you should always see a green icon next to a Workspace. By default, we will always bind to the last Workspace that you had open in a previous RTVS session.

All you need to do to switch between Workspaces is click on the right arrow icon of the Workspace that you would like to switch to. This will immediately terminate your current Workspace (but it will prompt whether you want to save your current session before you exit), before switching to the new Workspace. 

Since it is possible that the Workspace that you want to switch to is not available (i.e., you have uninstalled it, or in the case of a remote Workspace the computer is not reachable) you may wind up in a state where _no workspace is bound to your RTVS project_. You will realize this right away if you try to type a command into the REPL and it reports that no R interpreter is available to service your request. To fix this problem, simply select another Workspace from the list available, or in the unlikely event that _no workspaces are available_, you will need to install another R Interpreter.

### Differences between Local and Remote Workspaces

The promise of Local and Remote Workspaces is this: anything you can do locally, you can also do remotely and with a comparable user experience. However, Remote Workspaces is currently in Preview, and there are a number of known issues in the implementation. You can view the full list of issues by using [this query on Github](). There is one significant issue that I do want to make sure that you understand, and that is how RTVS deals with local and remote files. 

When you open a project (or, more typically a solution) using Visual Studio, the assumption is that the project and all of its associated files _reside on the same machine as Visual Studio_. This is a key design decision in Visual Studio, and it is unlikely to change anytime soon. What this means for RTVS is that we must first copy any files that you want to use on the remote machine before you can use them. 

There are a number of places where we automatically copy files on your behalf.

There are a number of places where _you must copy files explicitly to the remote machine_.

Clearly, this is not an ideal solution, but it was one that let us ship a Preview release to you earlier to get feedback on the overall Remote Workspaces feature. We are working on a better implementation of the file sync problem for a future release and welcome your ideas and feedback about how to make that a better experience for you.

