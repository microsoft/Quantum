---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
urlFragment: quantum-teleportation
description: "This sample demonstrates using Quantum Development Kit to move quantum data with quantum teleportation."
---

# Quantum Teleportation Sample

This sample demonstrates the use of the Quantum Development Kit for quantum teleportation, a sort of "hello, world" for quantum programming.

It shows how to call the teleport quantum samples from 3 different classical host programs, each implemented in a different programming platform:

* Jupyter Notebook
* Python
* C# 

## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample ##

This sample can be run in a number of different ways, depending on your preferred environment.

### Jupyter Notebook ###

From the command line, start Jupyter Notebook and open the [Notebook.ipynb](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/Notebook.ipynb) file.

```
jupyter notebook Notebook.ipynb
```

### Python in Visual Studio Code or the Command Line ###

At a terminal, run the following command:

```bash
python host.py
```

### C# in Visual Studio Code or the Command Line ###

At a terminal, run the following command:

```dotnetcli
dotnet run
```

### C# in Visual Studio 2019 ###

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `TeleportationSample.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [TeleportationSample.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/TeleportationSample.qs): Q# code defining how to teleport qubit states.
- [Utils.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/Utils.qs): Q# code with some utility operations used to prepare and read |+> and |-> states.
- [Host.cs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/Host.cs): C# code to call the operations defined in Q#.
- [TeleportationSample.csproj](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/TeleportationSample.csproj): Main C# project for the example.
- [host.py](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/host.py): a sample Python program to call the Q# teleport operation.
- [Notebook.ipynb](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/Notebook.ipynb): a Jupyter notebook that shows how to implement the Q# teleport operation.
