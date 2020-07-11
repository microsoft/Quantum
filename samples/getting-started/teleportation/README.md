---
page_type: sample
languages:
- qsharp
products:
- qdk
urlFragment: quantum-teleportation
description: "This sample demonstrates using Quantum Development Kit to move quantum data with quantum teleportation."
---

# Quantum Teleportation Sample

This sample demonstrates the use of the Quantum Development Kit for quantum teleportation, a sort of "hello, world" for quantum programming.

## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal. 

## Manifest ##

- [TeleportationSample.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/TeleportationSample.qs): Q# code defining how to teleport qubit states.
- [Utils.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/Utils.qs): Q# code with some utility operations used to prepare and read |+> and |-> states.
- [Program.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.
- [TeleportationSample.csproj](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/teleportation/TeleportationSample.csproj): Main Q# project for the example.
