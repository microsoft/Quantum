---
page_type: sample
languages:
- qsharp
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

To run the sample, use the `dotnet run` command from your terminal. 

## Manifest ##

- [HubbardSimulation.qs](./HubbardSimulation.qs): Q# code implementing quantum operations for this sample.
- [Program.qs](./Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.
- [HubbardSimulationSample.csproj](./HubbardSimulationSample.csproj): Main Q# project for the sample.
