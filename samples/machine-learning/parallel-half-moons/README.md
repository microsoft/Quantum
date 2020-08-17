---
page_type: sample
languages:
- qsharp
- csharp
products:
- qdk
description: "This sample implements using the quantum machine learning library to train a sequential model on the half-moons dataset, parallelizing over target machines."
---

# Training sequential models with Q#, using multiple simulators in parallel

This sample uses Q# and the Microsoft.Quantum.MachineLearning library to train a simple sequential model.
The model is trained on a half-moons dataset, loaded in C# using the System.Text.Json package, then preprocessed using Q#.

In this sample, the training loop is parallelized over model start points, with each model using its own instance of the full-state quantum simulator.
Parallelizing in this way can lead to significantly improved performance, especially when using a large number of cores on a small number of qubits.
The actual distribution of parallel tasks is performed using [Parallel LINQ (PLINQ)](https://docs.microsoft.com/dotnet/standard/parallel-programming/parallel-linq-plinq) from a C# host.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### C# in Visual Studio Code or the Command Line

At a terminal, run the following command:

```dotnetcli
dotnet run
```

### C# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `HalfMoons.csproj` as the startup project.
Press Start in Visual Studio to run the sample. 

## Manifest

- [Training.qs](https://github.com/microsoft/Quantum/blob/master/samples/machine-learning/half-moons/Training.qs): Q# code implementing quantum operations for this sample.
- [Host.cs](https://github.com/microsoft/Quantum/blob/master/samples/machine-learning/half-moons/Host.cs): C# code to load data, and to interact with and print out results of the Q# operations for this sample.
- [ParallelHalfMoons.csproj](https://github.com/microsoft/Quantum/blob/master/samples/machine-learning/half-moons/HalfMoons.csproj): Main C# project for the sample.
- [data.json](https://github.com/microsoft/Quantum/blob/master/samples/machine-learning/half-moons/data.json): JSON-serialized training and validation data used by this sample.
