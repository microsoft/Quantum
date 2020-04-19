---
page_type: sample
languages:
- qsharp
- python
- csharp
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

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### Python in Visual Studio Code or the Command Line

At a terminal, run the following command:

```bash
python host.py
```

### C# in Visual Studio Code or the Command Line

At a terminal, run the following command:

```dotnetcli
dotnet run
```

### C# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `Measurement.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest

- [Measurement.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/measurement/Measurement.qs): Q# code preparing and measuring a few qubits.
- [host.py](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/measurement/host.py): Python host program to call into the Q# sample.
- [Host.cs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/measurement/Host.cs): C# code to call the operations defined in Q#.
- [Measurement.csproj](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/measurement/Measurement.csproj): Main C# project for the sample.

## Further resources

- [Measurement concepts](https://docs.microsoft.com/quantum/concepts/pauli-measurements)
- [Logging and assertion techniques](https://docs.microsoft.com/quantum/techniques/testing-and-debugging#logging-and-assertions)
