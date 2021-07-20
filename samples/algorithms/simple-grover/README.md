---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample implements Grover's search algorithm, an example of a quantum development technique known as amplitude amplification."
---

# Searching with Grover's Algorithm

This sample implements Grover's search algorithm, an example of a quantum development technique known as _amplitude amplification_.
Oracles implementing the database are explicitly constructed together with all steps of the algorithm.
See the [DatabaseSearch](../database-search/README.md) sample for and extended version and the [Grover Search Kata](https://github.com/microsoft/QuantumKatas/tree/main/GroversAlgorithm) to learn more about Grover's algorithm and how to implement it in Q#.

This sample uses the example of an operation that marks inputs of the form "010101…", then uses Grover's algorithm to find these inputs given only the ability to call that operation.
In this case, the sample uses a hard-coded operation, but operations and functions in the [Microsoft.Quantum.AmplitudeAmplification namespace](https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.amplitudeamplification) can be used to efficiently and easily construct different inputs to Grover's algorithm, and to quickly build up useful variations of amplitude amplification for different applications.
For examples of how to solve more general problems using amplitude amplification, check out the more in-depth [database search sample](https://github.com/microsoft/Quantum/tree/main/samples/algorithms/database-search).

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### Q# in Visual Studio Code or the Command Line

At a terminal, run the following command:

```powershell
dotnet run
```

### Q# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder"
from the Getting Started screen or "File → Open → Folder..." from the menu bar)
and set `SimpleGroverSample.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest

- [SimpleGrover.qs](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/simple-grover/SimpleGrover.qs): Q# code implementing quantum operations for this sample.
- [Reflections.qs](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/simple-grover/Reflections.qs): Q# code implementing quantum operations for this sample.
- [SimpleGroverSample.csproj](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/simple-grover/SimpleGroverSample.csproj): Main Q# project for the sample.
