---
page_type: sample
author: guenp
description: Find Carmen using QRNG and Grover
ms.author: guenp@microsoft.com
ms.date: 08/09/2021
languages:
- qsharp
products:
- qdk
- azure-quantum
---

# Find Carmen with the Azure Quantum service

This sample demonstrates how to use Q# and the Azure Quantum service together to write a script that uses a Quantum Random Number Generator (QRNG) and Grover's algorithm to find Carmen, who fled to a random city in the world.
For more information about QRNG and Grover, please read the corresponding readme files.

This sample uses QRNG to place Carmen in a random spot in the world, based on a list of 7 cities, which is encoded in a Quantum Oracle using 3 qubits. Then, it runs Grover search using the oracle to find where Carmen is located. The more shots you use to run Grover, the more accurate your result will be.

This sample is implemented as a _standalone executable_. The program takes no command-line options.

## Running the sample on a local simulator

```dotnetcli
dotnet run -- --simulator QuantumSimulator
```

## Running the sample on the Azure Quantum service

Make sure that you have [created and selected a quantum workspace](https://docs.microsoft.com/azure/quantum/how-to-create-quantum-workspaces-with-the-azure-portal), and then run the following at the command line, substituting `TARGET` with the target that you would like to run against (e.g.: `ionq.qpu` or `honeywell.hqs-lt-1.0`):

```azcli
az quantum execute --target-id TARGET
```

For a full list of available QIO and quantum computing targets, run:

```azcli
az quantum target list --output table
```

> :warning:
> This sample makes use of paid services on Azure Quantum. The cost of running this sample *with the provided parameters* on IonQ in a Pay-As-You-Go subscription is approximately $6 USD (or the equivalent amount in your local currency). This quantity is only an approximate estimate and should not be used as a binding reference. The cost of the service might vary depending on your region, demand and other factors.

## Manifest

- [Carmen.csproj](https://github.com/microsoft/Quantum/blob/main/samples/azure-quantum/carmen/Carmen.csproj): Main Q# project for the sample.
- [Reflections.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/grover/Reflections.qs): Definitions for each reflection used in Grover's search.
- [SimpleGrover.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/grover/SimpleGrover.qs): Q# code implementing quantum operations for Grover's search algorithm.
- [Qrng.qs](https://github.com/microsoft/Quantum/blob/main/samples/azure-quantum/carmen/Qrng.qs): Q# code implementing quantum operations for QRNG.
- [Carmen.qs](https://github.com/microsoft/Quantum/blob/main/samples/azure-quantum/carmen/Carmen.qs): Q# code implementing quantum operations for this sample.
