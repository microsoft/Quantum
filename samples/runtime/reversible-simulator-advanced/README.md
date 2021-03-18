---
page_type: sample
languages:
- qsharp
- csharp
products:
- qdk
description: "This sample shows advanced techniques when using `IQuantumProcessor` interface."
---

# An advanced reversible simulator

This samples illustrates some advanced techniques to extend the functionality of
the simple reversible simulator.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

This sample can be run in a number of different ways, depending on your
preferred environment.

### C# in Visual Studio Code or the Command Line

At a terminal, run the following command (with example arguments for the inputs) in the `host` directory:

```dotnetcli
dotnet run -- -a true -b true -c false
```

The simulator included in this sample has been set as the default simulator in the Q# project file.
However, the simulator can also be specified explicitly using the `--simulator`/`-s` option.

```dotnetcli
dotnet run -- -a true -b true -c false -s Microsoft.Quantum.Samples.ReversibleSimulator
```

### C# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder"
from the Getting Started screen or "File → Open → Folder..." from the menu bar)
and set `host/host.csproj` as the startup project. Press Start in
Visual Studio to run the sample.

## Manifest

- [host/Program.qs](host/Program.qs): Q# code implementing quantum operations and control logic for this sample.
- [host/host.csproj](host/host.csproj): Runnable Q# project for the sample.
- [simulator/Simulator.cs](simulator/Simulator.cs): C# implementation of a reversible simulator using the `IQuantumProcessor` interface.
- [simulator/simulator.csproj](simulator/simulator.csproj): C# library project for the simulator.
