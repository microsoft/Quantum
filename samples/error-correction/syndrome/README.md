---
page_type: sample
languages:
- qsharp
- python
products:
- qdk
description: "This sample uses the Q# standard libraries to implement a syndrome for detecting errors in a given number of data qubits."
urlFragment: quantum-syndrome
---


# Measuring quantum error syndromes with Q\#

This sample demonstrates how to create a partially implemented Syndrome for detecting errors generated in noisy hardware. The sample shows how this is implemented using Q# standard libraries. Currently, it does not simulate realistic noise so the resulting unitary operator is trivial. However, the program is useful to demonstrate the concept of a syndrome.

The algorithm used is described in [Surface codes: Towards practical large-scale quantum computation](https://arxiv.org/abs/1208.0928) by Fowler et al. In particular, this example implements the circuit shown in Figure 1 c. in this paper.

The circuit uses _N data qubits_, where _N_ is a number given as input to the script, plus one _auxiliary_ qubit. The principle of the circuit is as follows. First, we prepare our data qubits in random states of a set of random bases, in order to simulate a noisy process. The circuit then propagates these errors to the auxiliary qubit using the principle of _phase kickback_. Phase kickback works by encoding pieces of a quantum algorithm into the global phase of an extra (auxiliary) qubit.

We start by preparing an auxiliary qubit into the superposition state by applying a `H` operation, to change to the _X_ computational basis. Subsequently, we apply controlled Pauli operators to each of the data qubits in random order, using the auxiliary qubit as control. The goal is to create a global phase shift on the auxiliary qubit, that will depend on the state of the data qubits. After the circuit runs, the auxiliary qubit is measured in the _X_-basis, which reveals its phase information.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

To run the sample, run `python syndrome.py --qubits <N>`, where `<N>` is replaced by the number of qubits. For more information, run `python syndrome.py --help`.

## Manifest

- [Syndrome.qs](https://github.com/microsoft/Quantum/blob/master/samples/error-correction/syndrome/Syndrome.qs): Q# code implementing quantum operations for this sample.
- [syndrome.py](https://github.com/microsoft/Quantum/blob/master/samples/error-correction/syndrome/syndrome.py): Python script to interact with and print out results of the Q# operations for this sample for a given number of data qubits. Example usage: `python syndrome.py --qubits 5`.
- [Syndrome.csproj](https://github.com/microsoft/Quantum/blob/master/samples/error-correction/syndrome/Syndrome.csproj): Main Q# project for the sample.

## Further resources

- [Error correction library concepts](https://docs.microsoft.com/quantum/libraries/standard/error-correction)
- [Pauli measurements](https://docs.microsoft.com/en-us/quantum/concepts/pauli-measurements)
