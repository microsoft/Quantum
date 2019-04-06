# Iterative Phase Estimation #

This sample demonstrates iterative phase estimation using Bayesian inference to provide a simple method to perform the classical statistical analysis.

## Running the Sample ##

Open the `QsharpLibraries.sln` solution in Visual Studio and set *Samples / 2. Characterization and Testing / PhaseEstimationSample* as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- **PhaseEstimation/**
  - [PhaseEstimationSample.csproj](./PhaseEstimationSample.csproj): Main C# project for the example.
  - [Program.cs](./Program.cs): C# code to call the operations defined in Q#.
  - [BayesianPhaseEstimation.qs](./BayesianPhaseEstimation.qs): The Q# implementation of iterative phase estimation and Bayesian inference.
