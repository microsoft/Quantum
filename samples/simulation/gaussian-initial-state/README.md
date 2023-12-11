---
page_type: sample
languages:
- qsharp
products:
- qdk
urlFragment: gaussian-initial-state
description: "This sample demonstrates using Quantum Development Kit to prepare the Gaussian initial state."
---

# Gaussian Initial State Sample

This sample demonstrates the use of the Quantum Development Kit for preparing the Gaussian initial state.

The goal of the algorithm is to prepare a quantum state that encodes the Gaussian wavefunction using probability amplitudes. The Gaussian state can be defined via a recursive definition, as described in [arXiv:0801.0342](https://arxiv.org/abs/0801.0342).

![Image of Gaussian state definition](https://github.com/microsoft/Quantum/blob/main/samples/simulation/gaussian-initial-state/gaussian_definition.jpg)

We implemented this algorithm in two ways in Q#. The first is as a `for` loop, following the approach outlined in [Guen Prawiroatmodjo's blog post](https://guenp.medium.com/preparing-a-gaussian-wave-function-in-q-695c3941f6dc). The second is by recursion.

In particular, the recursive approach calls the following subroutine, using the input data `(sigma0, mu0) = (sigma, mu)`.

1.
    1. Calculate `alpha` from `sigma` and `mu`.
    1. Apply the rotation operation `Ry(alpha, _)` to the 0th qubit.
1. Compute `(sigma1, mu1)`, where `sigma1 = sigma0 / 2.0` and `mu1 = mu0 / 2.0` if the previously rotated qubit is in the |0⟩ state, and `mu1 = (mu0 - 1) / 2.0` if it is in the |1⟩ state.
1. On the remaining `N - 1` qubits, prepare the state |_ψ_`(sigma1, mu1, N - 1)`⟩.

Note that after the last qubit, we proceed only through step 1 (b), as after this qubit is rotated we do not need another pair of parameters.

Both approaches use the [`ApplyControlledOnBitString` operation](https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.canon.applycontrolledonbitstring) in Q#.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal, passing which of the algorithms and how many qubits you'd like to use:

```powershell
dotnet run -- --recursive true --n-qubits 7
```

To plot the state prepared by this Q# program, you can use Q# + Python interoperability:

```bash
python host.py
```

## Manifest

- [PrepareGaussian.qs](https://github.com/microsoft/Quantum/blob/main/samples/simulation/gaussian-initial-state/PrepareGaussian.qs): Q# code defining how to prepare Gaussian state.
- [Program.qs](https://github.com/microsoft/Quantum/blob/main/samples/simulation/gaussian-initial-state/Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.
- [gaussian-initial-state.csproj](https://github.com/microsoft/Quantum/blob/main/samples/simulation/gaussian-initial-state/gaussian-initial-state.csproj): Main Q# project for the example.
