---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
description: "This sample demonstrates using Bayesian inference to learn phases of quantum operations."
urlFragment: iterative-phase-estimation
---

# Iterative Phase Estimation

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

```dotnetcli
dotnet run
```

### C# in Visual Studio 2019 ###

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `PhaseEstimationSample.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [PhaseEstimationSample.csproj](https://github.com/microsoft/Quantum/tree/master/samples/characterization/phase-estimation/PhaseEstimationSample.csproj): Main C# project for the example.
- [Host.cs](https://github.com/microsoft/Quantum/tree/master/samples/characterization/phase-estimation/Host.cs): C# code to call the operations defined in Q#.
- [host.py](https://github.com/microsoft/Quantum/tree/master/samples/characterization/phase-estimation/host.py): a sample Python program to call the Q# phase estimation operation.
- [BayesianPhaseEstimation.qs](https://github.com/microsoft/Quantum/tree/master/samples/characterization/phase-estimation/BayesianPhaseEstimation.qs): The Q# implementation of iterative phase estimation and Bayesian inference.
