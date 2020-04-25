---
page_type: sample
languages:
- qsharp
- csharp
products:
- qdk
description: "This sample describes three simple quantum algorithms."
urlFragment: simple-quantum-algorithms
---

# Simple Quantum Algorithms Sample

This sample describes three simple quantum algorithms: the Bernstein–Vazirani quantum algorithm to learn a parity function, the Deutsch–Jozsa quantum algorithm to distinguish constant Boolean functions from balanced ones, and the hidden shift quantum algorithm that identifies a shift pattern between so-called bent functions. 

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

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `SimpleAlgorithms.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest

- [SimpleAlgorithms.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/simple-algorithms/SimpleAlgorithms.qs): Q# code implementing quantum operations for this sample.
- [Host.cs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/simple-algorithms/Host.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [SimpleAlgorithms.csproj](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/simple-algorithms/SimpleAlgorithms.csproj): Main C# project for the sample.


