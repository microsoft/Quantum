---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample shows how to use synthesis techniques to implement arbitrary quantum oracles in Q#."
---

# Oracle Synthesis

This sample shows the implementation of an arbitrary quantum oracle function
using Hadamard gates, CNOT gates, and arbitrary Z-rotations.  The algorithm is
based on papers by N. Schuch and J. Siewert [[Programmable networks for quantum
algorithms](https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.91.027902),
*Phys. Rev. Lett.* **91**, 027902, 2003] and J. Welch, D. Greenbaum, S. Mostame,
and A. Aspuru-Guzik [[Efficient quantum circuits for diagonal unitaries without
ancillas](http://iopscience.iop.org/article/10.1088/1367-2630/16/3/033040/meta),
*New J. of Phys.* **16**, 033040, 2014].

This sample describes in detail the underlying concepts that were used to implement
the following operations from the [Q# Standard library](https://github.com/microsoft/QuantumLibraries/tree/master/Standard):

- [Microsoft.Quantum.Canon.ApplyAnd](https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.canon.applyand)
- [Microsoft.Quantum.Synthesis.ApplyXControlledOnTruthTable](https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.synthesis.applyxcontrolledontruthtable)
- [Microsoft.Quantum.Synthesis.ApplyXControlledOnTruthTableWithCleanTarget](https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.synthesis.applyxcontrolledontruthtablewithcleantarget)

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal.

## Manifest

- [OracleSynthesis.csproj](./OracleSynthesis.csproj): Main Q# project for the example.
- [OracleSynthesis.qs](./OracleSynthesis.qs): The Q# implementation for oracle synthesis.
- [Program.qs](./Program.qs): The Q# program entry point for the example.
