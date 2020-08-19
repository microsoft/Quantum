---
page_type: sample
languages:
- qsharp
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

To run the sample, use the `dotnet run` command from your terminal. Example: `dotnet run --n-qubits 4`

## Manifest

- [BernsteinVazirani.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/simple-algorithms/BernsteinVazirani.qs): Q# code implementing the Bernstein-Vazirani algorithm for this sample.
- [DeutschJozsa.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/simple-algorithms/DeutschJozsa.qs): Q# code implementing Deutsch-Jozsa algorithm for this sample.
- [HiddenShift.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/simple-algorithms/HiddenShift.qs): Q# code implementing hidden shift algorithm for this sample.
- [Program.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/simple-algorithms/Program.qs): Q# entry point to interact with and print out results of the test cases for this sample.
- [SimpleAlgorithms.csproj](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/simple-algorithms/SimpleAlgorithms.csproj): Main Q# project for the sample.
