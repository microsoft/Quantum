---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
---

# Quantum Teleportation Sample #

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

From the command line, start Jupyter Notebook and open the [Notebook.ipynb](./Notebook.ipynb) file.

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

```bash
dotnet run
```

### C# in Visual Studio 2019 ###

Open the `getting-started.sln` solution in Visual Studio and set `teleportation/TeleportationSample.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [TeleportationSample.qs](./TeleportationSample.qs): Q# code defining how to teleport qubit states.
- [Utils.qs](./Utils.qs): Q# code with some utility operations used to prepare and read |+> and |-> states.
- [Host.cs](./Program.cs): C# code to call the operations defined in Q#.
- [TeleportationSample.csproj](./TeleportationSample.csproj): Main C# project for the example.
- [host.py](./host.py): a sample Python program to call the Q# teleport operation.
- [Notebook.ipynb](./Notebook.ipynb): a Jupyter notebook that shows how to implement the Q# teleport operation.
