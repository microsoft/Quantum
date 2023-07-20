---
page_type: sample
author: cgranade
description: Simulate evolution under the Ising model with the Trotter–Suzuki decomposition, using the Azure Quantum service
ms.author: chgranad@microsoft.com
ms.date: 01/25/2021
languages:
- qsharp
products:
- qdk
- azure-quantum
---

# Simulating the Ising model on quantum hardware with the Trotter–Suzuki decomposition

This sample demonstrates how to use Q# and the Azure Quantum service together to simulate evolution under the [transverse Ising model](https://en.wikipedia.org/wiki/Transverse-field_Ising_model) by using the Trotter–Suzuki decomposition.

This sample is implemented as a _standalone executable_, such that no C# or Python host is needed.

## Running the sample on a local simulator

```dotnetcli
dotnet run -- --simulator QuantumSimulator --n-sites=5 --time=5.0 --dt=0.1
```

## Running the sample on the Azure Quantum service

Make sure that you have [created and selected a quantum workspace](https://docs.microsoft.com/azure/quantum/how-to-create-quantum-workspaces-with-the-azure-portal), and then run the following at the command line, substituting `TARGET` with the target that you would like to run against (e.g.: `ionq.qpu` or `quantinuum.qpu.h1`):

```azcli
az quantum execute --target-id TARGET -- --n-sites=5 --time=5.0 --dt=0.1
```

For a full list of available quantum computing targets, run:

```azcli
az quantum target list --output table
```

> :warning:
> This sample makes use of paid services on Azure Quantum. The cost of running this sample *with the provided parameters* on IonQ in a Pay-As-You-Go subscription is approximately $53 USD (or the equivalent amount in your local currency). This quantity is only an approximate estimate and should not be used as a binding reference. The cost of the service might vary depending on your region, demand and other factors.

## Manifest

- [IsingModel.csproj](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/ising-model/IsingModel.csproj): Main Q# project file for this sample.
- [IsingModel.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/ising-model/IsingModel.qs): Main Q# program for this sample.
