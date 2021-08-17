---
page_type: sample
languages:
- qsharp
products:
- qdk
urlFragment: h2-command-line
description: "This sample demonstrates using Quantum Development Kit to estimate ground state energies of molecular hydrogen."
---

# H₂ Simulation Sample (Command Line)

This sample demonstrates using Q# to estimate the ground state energy of molecular hydrogen (H₂), outputting the results to the command line.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

This sample can be run in different ways, depending on your preferred environment.

### Visual Studio Code or the Command Line

At a terminal, run the following command:

```dotnetcli
dotnet run
```

### Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `H2SimulationSampleCmdLine.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest

- [Operations.qs](https://github.com/microsoft/Quantum/blob/main/samples/simulation/h2/command-line/Operations.qs): Q# code defining how estimate H₂ energy levels.
- [Program.qs](https://github.com/microsoft/Quantum/blob/main/samples/simulation/h2/command-line/Host.cs): Q# entry point to call the operations defined in `Operations.qs`.
- [H2SimulationSampleCmdLine.csproj](https://github.com/microsoft/Quantum/blob/main/samples/simulation/h2/command-line/H2SimulationSampleCmdLine.csproj): Main C# project for the example.
