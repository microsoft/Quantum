---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates how to use the Q# standard libraries to simulate the Ising model."
urlFragment: ising-trotter
---

# Ising Trotter Sample

This sample walks through constructing the time-evolution operator for the Ising model using the Trotter–Suzuki decomposition provided with the Q# standard library. This time-evolution operator is applied to investigate spin relaxation.

## Running the Sample

Open the `QsharpSamples.sln` solution in Visual Studio and set the .csproj file in the manifest as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest

- [IsingTrotter.qs](./IsingTrotter.qs): Q# code implementing quantum operations for this sample.
- [Program.qs](./Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.
- [IsingTrotterSample.csproj](./IsingTrotterSample.csproj): Main C# project for the sample.
