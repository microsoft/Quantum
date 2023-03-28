---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates counting the resources required to run quantum numerics applications."
urlFragment: resource-counting-numerics
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

# Counting resources required for quantum numerics applications

This sample demonstrates:

- How to extend QCTraceSimulator in a Q# standalone applications to estimate the quantum resources required to run a Q# operation.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal:

```powershell
dotnet run
```

## Manifest

- [ResourceCounting.qs](./ResourceCounting.qs): Q# code implementing polynomial function evaluation.
- [Program.qs](./Program.qs): A Q# application that provides a specific polinomial for evaluation.
- [Program.cs](./Program.cs): C# driver to run Q# code with custom startup and shutdown.
- [ResourcesEstimator.cs](./ResourcesEstimator.cs): C# Resources Estimator that aggregates and prints data collected by QCTraceSimulator.
- [ResourceCounting.csproj](./ResourceCounting.csproj): Main Q# project for the sample.
