---
page_type: sample
languages:
- qsharp
- csharp
products:
- qdk
urlFragment: simulator-with-overrides
description: "This sample demonstrates using Quantum Development Kit to create a quantum simulator that relies on full state simulator and redefines some of the built-in operations (measurements)."
---

# Defining a Simulator with Built-in Operation Overrides

This sample demonstrates using Q# to create a quantum simulator that relies on full state simulator and redefines some of the built-in operations (using measurements as an example).

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### C# in Visual Studio Code or the Command Line

At a terminal, run the following command:

```dotnetcli
dotnet run
```

### C# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `SimulatorWithOverrides.csproj` as the startup project.
Press Start in Visual Studio to run the sample. 

## Manifest

- [FaultyMeasurementsSimulator.cs](https://github.com/microsoft/Quantum/blob/master/samples/runtime/simulator-with-overrides/FaultyMeasurementsSimulator.cs): C# code that defines the simulator and the operation overrides in it.
- [Operations.qs](https://github.com/microsoft/Quantum/blob/master/samples/runtime/simulator-with-overrides/Operations.qs): Q# code used to demonstrate the simulator behavior.
- [Host.cs](https://github.com/microsoft/Quantum/blob/master/samples/runtime/simulator-with-overrides/Host.cs): C# code to call the operations defined in Q#.
- [SimulatorWithOverrides.csproj](https://github.com/microsoft/Quantum/blob/master/samples/simulationruntime/simulator-with-overrides/SimulatorWithOverrides.csproj): Main C# project for the example.
