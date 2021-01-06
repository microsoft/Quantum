---
page_type: sample
languages:
- qsharp
products:
- qdk
urlFragment: gaussian_initial_state
description: "This sample demonstrates using Quantum Development Kit to prepare the Gaussian initial state."
---

# Gaussian Initial State Sample

This sample demonstrates the use of the Quantum Development Kit for preparing the Gaussian initial state.

## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal.
And then use the `python read_state.py` command from your terminal to read and plot the result state.
You can specify to either use the basic for-loop implementation or the recursive implementation in the Program.qs file. 

## Manifest ##

- [Gauss_wavefcn.qs](https://github.com/microsoft/Quantum/blob/main/samples/Gaussian_initial_state/Gauss_wavefcn.qs): Q# code defining how to prepare Gaussian state.
- [Program.qs](https://github.com/microsoft/Quantum/blob/main/samples/gaussian_initial_state/Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.
- [Gaussian_initial_state.csproj](https://github.com/microsoft/Quantum/blob/main/samples/gaussian_initial_state/Gaussian_initial_state.csproj): Main Q# project for the example.
- [read_state.py](https://github.com/microsoft/Quantum/blob/main/samples/gaussian_inital_state/read_state.py): Python code to plot the result quantum state of the Q# operations for this sample.