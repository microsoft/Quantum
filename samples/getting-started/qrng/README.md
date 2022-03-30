---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample implements a quantum random number generator using Q#, a good first example to teach how to use the language."
---

# Creating random numbers with quantum computing

This sample implements a quantum random number generator, a very simple application that is useful to learn how to write a first Q# program.

In the Q# code (Qrng.qs) you will find the Q# operation for extracting a random bit using quantum measurements over a qubit in superposition. For more information, you can take a look at the [full tutorial](https://docs.microsoft.com/azure/quantum/tutorial-qdk-quantum-random-number-generator).

You will also find a Q# operation that creates a random integer from 0 to a maximum integer by invoking several times the Q# operation for extracting a random bit.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).
- The [`qsharp` Python package](https://docs.microsoft.com/azure/quantum/install-python-qdk) (optional for usage with Python host program).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal. To run the sample via the Python host program, run `python host.py` from your terminal.

## Manifest

- [Qrng.qs](https://github.com/microsoft/Quantum/blob/main/samples/getting-started/qrng/Qrng.qs): Q# code implementing quantum operations for this sample.
- [host.py](https://github.com/microsoft/Quantum/blob/main/samples/getting-started/qrng/host.py): Python host program that imports and runs the sample.
- [Qrng.csproj](https://github.com/microsoft/Quantum/blob/main/samples/getting-started/qrng/Qrng.csproj): Main Q# project for the sample.
