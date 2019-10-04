---
page_type: sample
languages: [qsharp, python, csharp]
products: [qdk]
---

# Iterative Phase Estimation #

This sample demonstrates iterative phase estimation using Bayesian inference to provide a simple method to perform the classical statistical analysis.

## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample ##

This sample can be run in a number of different ways, depending on your preferred environment.


### Python in Visual Studio Code or the Command Line ###

At a terminal, run the following command:

```bash
python host.py
```

### C# in Visual Studio Code or the Command Line ###

At a terminal, run the following command:

```bash
dotnet run
```

### C# in Visual Studio 2019 ###

Open the `characterization.sln` solution in Visual Studio and set `phase-estimation/PhaseEstimationSample.csproj` as the startup project.
Press Start in Visual Studio to run the sample.


## Manifest ##

- [PhaseEstimationSample.csproj](./PhaseEstimationSample.csproj): Main C# project for the example.
- [Host.cs](./Host.cs): C# code to call the operations defined in Q#.
- [BayesianPhaseEstimation.qs](./BayesianPhaseEstimation.qs): The Q# implementation of iterative phase estimation and Bayesian inference.
