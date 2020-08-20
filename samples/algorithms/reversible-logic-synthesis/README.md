---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
description: "This sample shows how to use Q# to decompose reversible logic into quantum operations."
jupyter:
  jupytext:
    cell_markers: region,endregion
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.2'
      jupytext_version: 1.5.2
  kernelspec:
    display_name: .NET (PowerShell)
    language: PowerShell
    name: .net-powershell
---

# Reversible Logic Synthesis

This sample demonstrates:
- How to use Q# to decompose permutations into quantum operations.
- How to apply decomposed permutations in algorithms such as hidden shift.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### Python in Visual Studio Code or the Command Line

At a terminal, run the following command:

```powershell
python host.py
```

### Q# in Visual Studio Code or the Command Line

At a terminal, run the following command:

```powershell
dotnet run
```

### Q# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder"
from the Getting Started screen or "File → Open → Folder..." from the menu bar)
and set `ReversibleLogicSynthesis.csproj` as the startup project. 
Press Start in Visual Studio to run the sample. 

## Manifest

- [ReversibleLogicSynthesis.qs](https://github.com/microsoft/Quantum/blob/master/samples/algorithms/reversible-logic-synthesis/ReversibleLogicSynthesis.qs): Main Q# code for this sample.
- [host.py](https://github.com/microsoft/Quantum/blob/master/samples/algorithms/reversible-logic-synthesis/host.py): Python host program to call into the Q# sample.
- [ReversibleLogicSynthesis.csproj](https://github.com/microsoft/Quantum/blob/master/samples/algorithms/reversible-logic-synthesis/CHSHGame.csproj): Main Q# project for the sample.
