---
page_type: sample
languages:
- qsharp
- csharp
products:
- qdk
description: "This sample implements a simple reversible simulator for Q# using the `IQuantumProcessor` interface."
---

# A simple reversible simulator

This samples shows how to build a simple reversible simulator.  It is very
similar to the [existing Toffoli
simulator](https://docs.microsoft.com/quantum/machines/toffoli-simulator?view=qsharp-preview),
but presented as an example of how to use the `IQuantumProcessor` interface. A
reversible simulator can simulate quantum programs that consist only of
*classical* operations: `X`, `CNOT`, `CCNOT` (Toffoli gate), or arbitrarily
controlled `X` operations.  Since a reversible simulator can represent the
quantum state by assigning one Boolean value to each qubit, it can run even
quantum programs that consist of thousands of qubits. This simulator is very
useful for testing quantum operations that evaluate Boolean functions.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

This sample can be run in a number of different ways, depending on your
preferred environment.

### C# in Visual Studio Code or the Command Line

At a terminal, run the following command:

```dotnetcli
dotnet run
```

### C# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder"
from the Getting Started screen or "File → Open → Folder..." from the menu bar)
and set `ReversibleSimulator.csproj` as the startup project. Press Start in
Visual Studio to run the sample. 

## Manifest

- [Operation.qs](Operation.qs): Q# code implementing quantum operations for this sample.
- [Simulator.cs](Simulator.cs): C# implementation of a reversible simulator using the `IQuantumProcessor` interface.
- [Driver.cs](Driver.cs): C# code running the quantum operations with the reversible simulator.
- [reversible-simulator.csproj](reversible-simulator.csproj): C# project for the sample.
