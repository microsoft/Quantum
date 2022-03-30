---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates evaluating polynomial functions with the Q# numerics library."
urlFragment: evaluating-functions
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

# Evaluating polynomial functions in Q\#

This sample demonstrates:

- How to use the Q# numerics library to evaluate polynomial functions.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal:

```powershell
dotnet run
```

## Manifest

- [EvaluatePolynomial.qs](./EvaluatePolynomial.qs): Q# code implementing polynomial function evaluation.
- [Program.qs](./Program.qs): A Q# standalone application that uses and tests polynomial function evaluation.
- [EvaluatingFunctions.csproj](./EvaluatingFunctions.csproj): Main Q# project for the sample.
- [remez.py](./remez.py): A Python script for calculating polynomial coefficients approximating a given function, using Remez's algorithm.
