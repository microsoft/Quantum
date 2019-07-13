# Remote Development Container for Visual Studio Code (preview) #

This folder defines a _development container_ for the Quantum Development Kit samples to make it easier to get up and running with trying out Q# with C#, Python, and Jupyter Notebook.

## What is a Development Container? ##

Visual Studio Code allows for using [Docker](https://docs.microsoft.com/dotnet/standard/microservices-architecture/container-docker-introduction/docker-defined) to quickly define development environments, including all the compilers, command-line tools, libraries, and programming platforms you need to get up and running quickly.
Using the definitions provided in this folder, Visual Studio Code can use Docker to automatically install the correct version of the Quantum Development Kit as well as other software you might want to use with Q#, such as Python and Jupyter Notebook --- all into an isolated container that doesn't affect the rest of the software you have on your system.

Next steps:
- [Visual Studio Code: Developing inside a container](https://code.visualstudio.com/docs/remote/containers)

## Getting Started ##

To use this development container, follow the installation instructions on the [Visual Studio Code site](https://code.visualstudio.com/docs/remote/containers#_installation) to prepare your machine to use development containers such as this one.
Once you have done so, clone the [**microsoft/quantum**](https://github.com/microsoft/quantum) repository and open the folder in Visual Studio Code.
You should be prompted to reopen the folder for remote development in the development container; if not, make sure that you have the right extension installed from above.

Once you follow the prompt, Visual Studio Code will automatically configure your development container by installing the Quantum Development Kit into a new image, including installing the .NET Core SDK, project templates, Jupyter Notebook support, and the Python host package.
This process will take a few moments, but once it's complete, you can then open a new shell as normal in Visual Studio Code; this shell will open a command line in your new development container
The Quantum Development Kit samples will be available in the `/workspace/Quantum/` folder of your development container, so you can easily run the different samples using either `dotnet run` or `python host.py` as appropriate:

```bash
jovyan@a53c675705c1:/workspaces/Quantum$ cd Samples/src/Teleportation/
jovyan@a53c675705c1:/workspaces/Quantum/Samples/src/Teleportation$ dotnet run
Round 0:        Sent True,      got True.
Teleportation successful!!

Round 1:        Sent True,      got True.
Teleportation successful!!

Round 2:        Sent False,     got False.
Teleportation successful!!

Round 3:        Sent False,     got False.
Teleportation successful!!

Round 4:        Sent True,      got True.
Teleportation successful!!

Round 5:        Sent False,     got False.
Teleportation successful!!

Round 6:        Sent True,      got True.
Teleportation successful!!

Round 7:        Sent True,      got True.
Teleportation successful!!

jovyan@a53c675705c1:/workspaces/Quantum/Samples/src/Teleportation$ python host.py
Preparing Q# environment...
['Microsoft.Quantum.Samples.Teleportation.IsMinus', 'Microsoft.Quantum.Samples.Teleportation.IsPlus', 'Microsoft.Quantum.Samples.Teleportation.PrepareRandomMessage', 'Microsoft.Quantum.Samples.Teleportation.SetToMinus', 'Microsoft.Quantum.Samples.Teleportation.SetToPlus', 'Microsoft.Quantum.Samples.Teleportation.Teleport', 'Microsoft.Quantum.Samples.Teleportation.TeleportClassicalMessage', 'Microsoft.Quantum.Samples.Teleportation.TeleportRandomMessage']
Sending |->
Received |->
------------------
Sent True, Received: True
Sent False, Received: False
------------------
Estimated resources needed for teleport:
 {'CNOT': 2, 'QubitClifford': 4, 'R': 0, 'Measure': 8, 'T': 0, 'Depth': 0, 'Width': 3, 'BorrowedWidth': 0}
------------------
Sending |+>
Received |+>
------------------
Sending |+>
Received |+>
------------------
Sending |->
Received |->
------------------
Sending |+>
Received |+>
------------------
Sending |+>
Received |+>
------------------
Sending |->
Received |->
------------------
Sending |->
Received |->
------------------
Sending |+>
Received |+>
------------------
Sending |->
Received |->
------------------
Sending |+>
Received |+>
------------------
```

### Using Jupyter Notebook from a Development Container ###

You can also use Jupyter Notebook, but this currently requires a couple additional steps.
First, you need to make sure to pass the argument `--ip=0.0.0.0` when starting a new Jupyter Notebook session, as this is currently required when running in a development container:

```bash
jovyan@a53c675705c1:/workspaces/Quantum/$ jupyter notebook --ip=0.0.0.0
```

This should print out a few lines, including the token needed to access your new notebook.
For example:

```bash
[C 16:45:17.660 NotebookApp]

    To access the notebook, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/nbserver-473-open.html
    Or copy and paste one of these URLs:
        http://(a53c675705c1 or 127.0.0.1):8888/?token=c6338ab860bb6cdf7f976a4676b6a2a8d2e3dc84107a0abd
```

We'll need this token in a moment, so copy the token to your clipboard by highlighting everything after `?token=` and right-clicking.
Next, make your new notebook available outside your development container by pressing Ctrl+Shift+P or ⌘+Shift+P to bring up the Command Palette and selecting "Remote-Containers: Forward Port from Container..."
In a few moments, Visual Studio Code should automatically suggest forwarding port 8888.
Select this, and open your web browser using the prompt provided by Visual Studio Code.
Paste the token into the page that opens and you should be good to go!


