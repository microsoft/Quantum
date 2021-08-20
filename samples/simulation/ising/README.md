---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "These samples demonstrate how to use Q# to simulate the Ising model."
urlFragment: ising
---

# Ising Model Simulation Samples

These samples demonstrate how to use Q# to simulate the Ising model.

- **[Simple Ising](#simple-ising-sample)**: This sample walks through constructing the time-evolution operator for the Ising model.
- **[Ising Generators](#ising-generators-sample)**: This sample describes how Hamiltonians may be represented using Microsoft.Quantum.Canon functions.
- **[Adiabatic Ising Evolution](#adiabatic-ising-evolution-sample)**: This sample converts a representation of a Hamiltonian using library data types into unitary time-evolution by the Hamiltonian on qubits.
- **[Ising Phase Estimation](#ising-phase-estimation-sample)**: This sample adiabatically prepares the ground state of the Ising model Hamiltonian, and then perform phase estimation to obtain an estimate of the ground state energy.
- **[Ising Trotter Evolution](#ising-trotter-sample)**: This sample walks through constructing the time-evolution operator for the Ising model using the Trotterization library feature.

## Manifest

- [IsingSamples.csproj](./IsingSamples.csproj): Main Q# project for all of the Ising samples.

## Running the Samples

### In Visual Studio Code or the Command Line

At a terminal, run the command line listed in the section for each sample below.

### In Visual Studio 2019

Open the `simulation.sln` solution in Visual Studio and set the .csproj file in the manifest as the startup project.
Set the command-line arguments to `simulate <entry point>`, replacing `<entry point>` with the name of the sample's entry point.
Press Start in Visual Studio to run the sample.

## Simple Ising Sample

This sample walks through constructing the time-evolution operator for the Ising model manually.
This time-evolution operator is applied to adiabatically prepare the ground state of the Ising model.
The net magnetization is then measured.

### Command Line

```powershell
dotnet run simulate Microsoft.Quantum.Samples.Ising.RunSimple
```

### Manifest

- [SimpleIsing.qs](./simple/SimpleIsing.qs): Q# code implementing quantum operations for this sample.
- [Program.qs](./simple/Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.

## Ising Generators Sample

This sample describes how Hamiltonians may be represented using library functions.
The Ising model is decomposed into single-site and two-site terms which are added.
A simple extension to the Heisenberg model is also illustrated.

### Command Line

```powershell
dotnet run simulate Microsoft.Quantum.Samples.Ising.RunGenerators
```

### Manifest

- [IsingGenerators.qs](./generators/IsingGenerators.qs): Q# code implementing quantum operations for this sample.
- [Program.qs](./generators/Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.

## Adiabatic Ising Evolution Sample

This sample converts a representation of a Hamiltonian operator using library data types into unitary time-evolution by the Hamiltonian on qubits.
We consider the Ising model and study adiabatic state preparation of its ground state for the cases of uniform ferromagnetic and anti-ferromagnetic coupling between sites.

### Command Line

```powershell
dotnet run simulate Microsoft.Quantum.Samples.Ising.RunAdiabaticEvolution
```

### Manifest

- [AdiabaticIsing.qs](./adiabatic/AdiabaticIsing.qs): Q# code implementing quantum operations for this sample.
- [Program.qs](./adiabatic/Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.

### Related Samples

This sample builds on results in the [Ising Generators](#ising-generators-sample) sample.
We suggest reading that sample before continuing.

## Ising Phase Estimation Sample

This sample adiabatically prepares the ground state of the Ising model Hamiltonian, and then perform phase estimation to obtain an estimate of the ground state energy.

### Command Line

```powershell
dotnet run simulate Microsoft.Quantum.Samples.Ising.RunPhaseEstimation
```

### Manifest

- [IsingPhaseEstimation.qs](./phase-estimation/IsingPhaseEstimation.qs): Q# code implementing quantum operations for this sample.
- [Program.qs](./phase-estimation/Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.

### Related Samples

This sample builds on results in [Adiabatic Ising Evolution](#adiabatic-ising-evolution-sample) and uses techniques introduced in [Ising Phase Estimation](#ising-phase-estimation-sample).
We suggest reading those samples before continuing.

## Ising Trotter Sample

This sample walks through constructing the time-evolution operator for the Ising model using the Trotter–Suzuki decomposition provided with the Q# standard library.
This time-evolution operator is applied to investigate spin relaxation.

### Command Line

```powershell
dotnet run simulate Microsoft.Quantum.Samples.Ising.RunTrotter
```

### Manifest

- [IsingTrotter.qs](./trotter-evolution/IsingTrotter.qs): Q# code implementing quantum operations for this sample.
- [Program.qs](./trotter-evolution/Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.
