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

- How to configure project files for Q# standalone applications to estimate the quantum resources required to run a Q# operation.
- How to use the [`%estimate` magic command](https://docs.microsoft.com/qsharp/api/iqsharp-magic/estimate) provided by the IQ# kernel to estimate the quantum resources required to run a Q# operation.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal:

```powershell
dotnet run
```

The **.csproj** file provided for this Q# standalone application sets the default simulator to be `ResourcesEstimator`, such that the above command will report the resources required to run the Q# program.

This sample can also be used as a Q# notebook:

```shell
jupyter notebook
```

## Manifest

- [ResourceCounting.qs](./ResourceCounting.qs): Q# code implementing polynomial function evaluation.
- [Program.qs](./Program.qs): A Q# standalone application for use with the `-s ResourcesEstimator` option.
- [ResourceCounting.csproj](./ResourceCounting.csproj): Main Q# project for the sample.
- [ResourceCounting.ipynb](./ResourceCounting.ipynb): A Jupyter Notebook version of the sample.
