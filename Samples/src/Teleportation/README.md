# Quantum Teleportation Sample #

This sample demonstrates the use of the Quantum Development Kit for quantum teleportation, a sort of "hello, world" for quantum programming.

It shows how to call the teleport quantum samples from 3 different classical drivers, each implemented in a different programming platform:
* Jupyter notebook
* Python
* C# 

## Running the Sample ##

### Jupyter notebook ###

Follow the [IQ# installation instructions](https://docs.microsoft.com/en-us/quantum/install-guide/jupyter?), then from the command line
start jupyter notebook and open the [Notebook.ipynb](./Notebook.ipynb) file.
```
jupyter notebook Notebook.ipynb
```

### Python ###

Follow the [getting started with Python instructions for Q#](https://docs.microsoft.com/en-us/quantum/install-guide/python?), then from the command line
run the [host.py](./host.py) file using Python:
```
python host.py
```

### C# ###

From the command line, run:
```
dotnet run
```

Optionally, open the `QsharpSamples.sln` solution in Visual Studio and set *Samples / 0. Introduction / TeleportationSample* as the startup project.
Press Start in Visual Studio to run the example.

## Manifest ##

- [TeleportationSample.qs](./TeleportationSample.qs): Q# code defining how to teleport qubit states.
- [Utils.qs](./Utils.qs): Q# code with some utility operations used to prepare and read |+> and |-> states.
- [Program.cs](./Program.cs): C# code to call the operations defined in Q#.
- [TeleportationSample.csproj](./TeleportationSample.csproj): Main C# project for the example.
- [host.py]: a sample Python code to call the Q# teleport operation.
- [Notebook.ipynb]: a Jupyter notebook that shows how to implement the Q# teleport operation.
