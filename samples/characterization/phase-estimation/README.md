---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates using Bayesian inference to learn phases of quantum operations."
urlFragment: iterative-phase-estimation
---

# Iterative Phase Estimation

This sample demonstrates iterative phase estimation using Bayesian inference to provide a simple method to perform the classical statistical analysis. You can read more about iterative phase estimation in [our documentation on quantum characterization and statistics](https://docs.microsoft.com/quantum/libraries/standard/characterization#iterative-phase-estimation).

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

To run the sample, use the `dotnet run` command from your terminal. 

## Manifest

- [PhaseEstimationSample.csproj](https://github.com/microsoft/Quantum/tree/master/samples/characterization/phase-estimation/PhaseEstimationSample.csproj): Main Q# project for the example.
- [BayesianPhaseEstimation.qs](https://github.com/microsoft/Quantum/tree/master/samples/characterization/phase-estimation/BayesianPhaseEstimation.qs): The Q# implementation of iterative phase estimation and Bayesian inference.
- [Program.qs](https://github.com/microsoft/Quantum/tree/master/samples/characterization/phase-estimation/Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.
