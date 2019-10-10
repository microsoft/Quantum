---
page_type: sample
languages: [qsharp, python, csharp]
products: [qdk]
---

# Searching with Grover's Algorithm #

This sample implements Grover's search algorithm.
Oracles implementing the database are explicitly constructed together with all steps of the algorithm.
See the [DatabaseSearch](../database-search/README.md) sample for and extended version and the [Grover Search Kata](https://github.com/microsoft/QuantumKatas/tree/master/GroversAlgorithm) to learn more about Grover's algorithm and how to implement it in Q#.

## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample ##

This sample can be run in a number of different ways, depending on your preferred environment.

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

Open the `algorithms.sln` solution in Visual Studio and set the .csproj file in the manifest as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [SimpleGrover.qs](./SimpleGrover.qs): Q# code implementing quantum operations for this sample.
- [Host.cs](./Host.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [SimpleGroverSample.csproj](./SimpleGroverSample.csproj): Main C# project for the sample.
