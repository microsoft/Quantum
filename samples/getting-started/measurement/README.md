---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates the use of measurement operations to measure one or more qubits."
urlFragment: measuring-qubits
---

# Measuring Qubits

This sample demonstrates:
- The use of measurement operations to measure one or more qubits, getting classical data back that can be used in classical logic.
- How to use assertions to build tests for expected behaviour of operations that involve measurements.
- Resetting previously allocated qubits.

In Q#, the most basic measurement operation is the [`M`](https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.m) operation, which measures a single qubit in the _computational basis_ (sometimes also called the 𝑍-basis).
In this sample, we show how `M` can be used to sample random numbers, and to measure registers of qubits.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal. 

## Manifest

- [Measurement.qs](https://github.com/microsoft/Quantum/blob/main/samples/getting-started/measurement/Measurement.qs): Q# code preparing and measuring a few qubits.
- [Measurement.csproj](https://github.com/microsoft/Quantum/blob/main/samples/getting-started/measurement/Measurement.csproj): Main Q# project for the sample.

## Further resources

- [Measurement concepts](https://docs.microsoft.com/azure/quantum/concepts-pauli-measurements)
- [Facts and assertion techniques](https://docs.microsoft.com/azure/quantum/user-guide/testing-debugging#facts-and-assertions)
