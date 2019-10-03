---
page_type: sample
languages: [qsharp, csharp]
products: [qdk]
---

# Simple Quantum Algorithms Sample #

This sample describes three simple quantum algorithms: the Bernstein–Vazirani quantum algorithm to learn a parity function, the Deutsch–Jozsa quantum algorithm to distinguish constant Boolean functions from balanced ones, and the hidden shift quantum algorithm that identifies a shift pattern between so-called bent functions. 

## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample ##

This sample can be run in a number of different ways, depending on your preferred environment.

### C# in Visual Studio Code or the Command Line ###

At a terminal, run the following command:

```bash
dotnet run
```

### C# in Visual Studio 2019 ###

Open the `getting-started.sln` solution in Visual Studio and set `simple-algorithms/SimpleAlgorithms.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [SimpleAlgorithms.qs](./SimpleAlgorithms.qs): Q# code implementing quantum operations for this sample.
- [Host.cs](./Host.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [SimpleAlgorithms.csproj](./SimpleAlgorithms.csproj): Main C# project for the sample.

