---
page_type: sample
author: cgranade
description: Search unstructured data on quantum hardware, using the Azure Quantum service
ms.author: chgranad@microsoft.com
ms.date: 01/25/2021
languages:
- qsharp
products:
- qdk
- azure-quantum
---

# Simple Grover's search with the Azure Quantum service

This sample demonstrates how to use Q# and the Azure Quantum service together to search for data with Grover's algorithm, also known as amplitude amplification.
By applying a sequence of reflections, this state prepares a register of qubits in a state marked by a given quantum operation known as an _oracle_.
The oracle used in this sample checks if its input matches a given integer, so that the computational basis state corresponding to that index is prepared with high probability.

This sample is implemented as a _standalone executable_, such that no C# or Python host is needed.
The program takes one command-line option, `--n-qubits`, to control the number of qubits that are prepared using amplitude amplification.

## Q# standalone command-line

### Running the sample on a local simulator

```dotnetcli
dotnet run -- --simulator QuantumSimulator --n-qubits=3 --idx-marked=6
```

### Running the sample on the Azure Quantum service

Make sure that you have [created and selected a quantum workspace](https://docs.microsoft.com/azure/quantum/how-to-create-quantum-workspaces-with-the-azure-portal), and then run the following at the command line, substituting `TARGET` with the target that you would like to run against (e.g.: `ionq.qpu` or `quantinuum.qpu.h1`):

```azcli
az quantum execute --target-id TARGET -- --n-qubits=3 --idx-marked=6
```

For a full list of available quantum computing targets, run:

```azcli
az quantum target list --output table
```

> :warning:
> This sample makes use of paid services on Azure Quantum. The cost of running this sample *with the provided parameters* on IonQ in a Pay-As-You-Go subscription is approximately $6 USD (or the equivalent amount in your local currency). This quantity is only an approximate estimate and should not be used as a binding reference. The cost of the service might vary depending on your region, demand and other factors.

## Q# with Jupyter Notebook

Make sure that you have followed the [Q# + Jupyter Notebook quickstart](https://docs.microsoft.com/azure/quantum/install-jupyter-qdk) for the Quantum Development Kit, and then start a new Jupyter Notebook session from the folder containing this sample:

```shell
cd grover
jupyter notebook
```

Once Jupyter starts, open the `Grover.ipynb` notebook and follow the instructions there.

## Manifest

- [Grover.csproj](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/grover/Grover.csproj): Main Q# project file for this sample.
- [Reflections.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/grover/Reflections.qs): Definitions for each reflection used in Grover's search.
- [SimpleGrover.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/grover/SimpleGrover.qs): Main Q# program for this sample.
- [Grover.ipynb](./Grover.ipynb): Q# notebook for this sample.
