---
page_type: sample
author: cgranade
description: Find hidden shifts in Boolean functions, using the Azure Quantum service
ms.author: chgranad@microsoft.com
ms.date: 01/25/2021
languages:
- qsharp
- python
products:
- qdk
- azure-quantum
---

# Finding hidden shift of bent functions using the Azure Quantum service

This sample demonstrates how to use Q# and Azure Quantum together to learn the hidden shift of bent functions.

This sample is implemented as a _standalone executable_, such that no C# or Python host is needed.
The program takes one command-line option, `--n-qubits`, to control the number of qubits used to sample a random number.

## Running the sample on a local simulator

```dotnetcli
dotnet run -- --simulator QuantumSimulator --pattern-int 6 --register-size 3
```

## Running the sample on Azure Quantum

Make sure that you have [created and selected a quantum workspace](https://docs.microsoft.com/azure/quantum/how-to-create-quantum-workspaces-with-the-azure-portal), and then run the following at the command line, substituting `TARGET` with the target that you would like to run against (e.g.: `ionq.qpu` or `quantinuum.qpu.h1`):

```azcli
az quantum execute --target-id TARGET -- --pattern-int 6 --register-size 3
```

For a full list of available quantum computing targets, run:

```azcli
az quantum target list --output table
```

> :warning:
> This sample makes use of paid services on Azure Quantum. The cost of running this sample *with the provided parameters* on IonQ in a Pay-As-You-Go subscription is approximately $1-$2 USD (or the equivalent amount in your local currency). This quantity is only an approximate estimate and should not be used as a binding reference. The cost of the service might vary depending on your region, demand and other factors.

## Manifest

- [HiddenShift.csproj](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/hidden-shift/HiddenShift.csproj): Main Q# project file for this sample.
- [HiddenShift.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/hidden-shift/HiddenShift.qs): Main Q# program for this sample.
- [hidden-shift.ipynb](./hidden-shift.ipynb): Python + Qiskit version demonstrating usage with the Azure Quantum service.
