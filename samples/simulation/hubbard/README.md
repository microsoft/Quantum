---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
urlFragment: hubbard-simulation
description: "This sample demonstrates using Quantum Development Kit to simulate time evolution under the 1D Hubbard model."
---

# Hubbard Simulation Sample

This sample walks through constructing the time-evolution operator for the 1D Hubbard Simulation model.
This time-evolution operator is applied to project onto the ground state of the Hubbard Hamiltonian using phase estimation.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### Python in Visual Studio Code or the Command Line

At a terminal, run the following command:

```bash
python host.py
```

### C# in Visual Studio Code or the Command Line

At a terminal, run the following command:

```dotnetcli
dotnet run
```

### C# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `HubbardSimulationSample.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [HubbardSimulation.qs](./HubbardSimulation.qs): Q# code implementing quantum operations for this sample.
- [Host.cs](./Host.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [HubbardSimulationSample.csproj](./HubbardSimulationSample.csproj): Main C# project for the sample.
- [host.py](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/host.py): a sample Python program to call the Q# simulation operation.