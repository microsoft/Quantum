---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
description: "This sample implements using the quantum machine learning library to train a sequential model on the half-moons dataset."
---

# Training sequential models with Q#, using data loaded from JSON

This sample uses Q# and the Microsoft.Quantum.MachineLearning library to train a simple sequential model.
The model is trained on a half-moons dataset, loaded in C# using the System.Text.Json package or in Python using the `json` module, then preprocessed using Q#.


## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### Python in Visual Studio Code or the Command Line ###

This sample also uses a couple extra Python packages to help out, so you'll need to have those 
ready as well. If you are using the Anaconda distribution of Python, this can be done automatically by using 
the `environment.yml` file provided with this sample:

```bash
cd samples/machine-learning/half-moons
conda env create -f environment.yml
conda activate qsharp-sample-classifier
```

At a terminal, run the following command:

```bash
python host.py
```

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
- [Host.py](https://github.com/microsoft/Quantum/blob/master/samples/machine-learning/half-moons/host.py): Python code to load data, and to interact with and print out results of the Q# operations for this sample.
- [Host.cs](https://github.com/microsoft/Quantum/blob/master/samples/machine-learning/half-moons/Host.cs): C# code to load data, and to interact with and print out results of the Q# operations for this sample.
- [HalfMoons.csproj](https://github.com/microsoft/Quantum/blob/master/samples/machine-learning/half-moons/HalfMoons.csproj): Main C# project for the sample.
- [data.json](https://github.com/microsoft/Quantum/blob/master/samples/machine-learning/half-moons/data.json): JSON-serialized training and validation data used by this sample.
