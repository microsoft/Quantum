---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates how to implement a custom modular addition operation in Q#."
urlFragment: custom-modular-addition
---

# Implementing a custom modular addition operator in Q\#

This sample demonstrates:

- How to implement a custom modular integer addition operation in Q#.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal:

```powershell
dotnet run
```

## Manifest

- [CustomModAdd.qs](./CustomModAdd.qs): Q# code implementing a custom modular integer adder.
- [Program.qs](./Program.qs): A Q# standalone application that uses and tests the custom modular integer adder.
- [CustomModAdd.csproj](./CustomModAdd.csproj): Main Q# project for the sample.
