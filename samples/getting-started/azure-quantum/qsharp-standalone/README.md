---
page_type: sample
author: cgranade
description: Get started submitting Q# programs to the Azure Quantum service
ms.author: chgranad@microsoft.com
ms.date: 09/27/2021
languages:
- qsharp
products:
- qdk
- azure-quantum
---

# Get started using Python to submit Q# programs to the Azure Quantum service

This sample demonstrates how to use Q# and the Azure Quantum service together to build a quantum random number generator (QRNG).
In particular, this sample uses a register of qubits rather than a single qubit to draw random numbers several bits at a time, avoiding the need for intermediate measurement.

The Q# program in this sample can be run either at the command line, or in a Jupyter Notebook.

## Command-line

To run this sample locally on a simulator:

```dotnetcli
dotnet run -- --simulator QuantumSimulator --n-qubits=4
```

To submit this sample as a job to an Azure Quantum provider,, ake sure that you have [created and selected a quantum workspace](https://docs.microsoft.com/azure/quantum/how-to-create-quantum-workspaces-with-the-azure-portal), and then run the following at the command line, substituting `TARGET` with the target that you would like to run against (e.g.: `ionq.qpu` or `honeywell.hqs-lt-1.0`):

```azcli
az quantum execute --target-id TARGET -- --n-qubits=4
```

For a full list of available QIO and quantum computing targets, run:

```azcli
az quantum target list --output table
```

## Q# with Jupyter Notebook

Make sure that you have followed the [Q# + Jupyter Notebook quickstart](https://docs.microsoft.com/azure/quantum/install-jupyter-qdk) for the Quantum Development Kit, and then start a new Jupyter Notebook session from the folder containing this sample:

```shell
cd qsharp-standalone
jupyter notebook
```

Once Jupyter starts, open the `ParallelQrng.ipynb` notebook and follow the instructions there.

> :warning:
> This sample makes use of paid services on Azure Quantum. The cost of running this sample *with the provided parameters* on IonQ in a Pay-As-You-Go subscription is approximately $1-$2 USD (or the equivalent amount in your local currency). This quantity is only an approximate estimate and should not be used as a binding reference. The cost of the service might vary depending on your region, demand and other factors.

## Manifest

- [ParallelQrng.csproj](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/parallel-qrng/ParallelQrng.csproj): Main Q# project file for this sample.
- [ParallelQrng.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/parallel-qrng/ParallelQrng.qs): Main Q# program for this sample.
- [ParallelQrng.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/parallel-qrng/ParallelQrng.ipynb): IQ# notebook for this sample.
