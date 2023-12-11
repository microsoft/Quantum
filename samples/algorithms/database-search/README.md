---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample shows how to use Q# to search for a marked item with Grover's algorithm."
---

# Database Search Sample

This sample walks through Grover's search algorithm.
Oracles implementing the database are explicitly constructed together with all steps of the algorithm.

This sample features three examples:

1. A search made without any Grover iterations, equivalent to a random classical search.
2. A quantum search using manually implemented Grover iterations to amplify the marked element.
3. A quantum search using operations from the Q# standard library to amplify multiple marked elements.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### Visual Studio Code or the Command Line

At a terminal, run the following commands for each of the three examples.

#### Example 1

```powershell
dotnet run simulate Microsoft.Quantum.Samples.DatabaseSearch.RunRandomSearch
```

#### Example 2

```powershell
dotnet run simulate Microsoft.Quantum.Samples.DatabaseSearch.RunQuantumSearch
```

#### Example 3

```powershell
dotnet run simulate Microsoft.Quantum.Samples.DatabaseSearch.RunMultipleQuantumSearch
```

### Running the Sample in Jupyter Notebook

This sample can also be viewed using Jupyter Notebook.
To do so, ensure that you have the IQ# kernel installed using the instructions in the [getting started guide](https://docs.microsoft.com/azure/quantum/install-jupyter-qdk).
Then, start a new Jupyter Notebook session from this directory:

```powershell
cd Samples/src/DatabaseSearch
jupyter notebook
```

## Manifest

- [DatabaseSearch.qs](./DatabaseSearch.qs): Q# code implementing quantum operations for this sample.
- [Program.qs](./Program.qs): Q# code to interact with and print out results of the Q# operations for this sample.
- [DatabaseSearchSample.csproj](./DatabaseSearchSample.csproj): Main C# project for the sample.
- [Database Search.ipynb](./Database%20Search.ipynb): The sample as a Jupyter Notebook.
