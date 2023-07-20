---
page_type: sample
author: cgranade
description: Generate random numbers in parallel on quantum hardware, using the Azure Quantum service
ms.author: chgranad@microsoft.com
ms.date: 01/25/2021
languages:
- qsharp
- csharp
- python
products:
- qdk
- azure-quantum
---

# Parallel quantum random number generator (QRNG) sample

This sample demonstrates how to use Q# and the Azure Quantum service together to build a quantum random number generator (QRNG).
In particular, this sample uses a register of qubits rather than a single qubit to draw random numbers several bits at a time, avoiding the need for intermediate measurement.

This sample is implemented as a _standalone executable_, such that no C# or Python host is needed.
The program takes one command-line option, `--n-qubits`, to control the number of qubits used to sample a random number.

This sample can be run in one of three different ways, depending on your preferred environment:

- Q# standalone at the command-line
- Q# standalone from Jupyter Notebook
- Q# from a Python host program

## Q# standalone command-line

### Running the sample on a local simulator

```dotnetcli
dotnet run -- --simulator QuantumSimulator --n-qubits=4
```

### Running the sample on the Azure Quantum service

Make sure that you have [created and selected a quantum workspace](https://docs.microsoft.com/azure/quantum/how-to-create-quantum-workspaces-with-the-azure-portal), and then run the following at the command line, substituting `TARGET` with the target that you would like to run against (e.g.: `ionq.qpu` or `quantinuum.qpu.h1`):

```azcli
az quantum execute --target-id TARGET -- --n-qubits=4
```

For a full list of available quantum computing targets, run:

```azcli
az quantum target list --output table
```

## Q# with Jupyter Notebook

Make sure that you have followed the [Q# + Jupyter Notebook quickstart](https://docs.microsoft.com/azure/quantum/install-jupyter-qdk) for the Quantum Development Kit, and then start a new Jupyter Notebook session from the folder containing this sample:

```shell
cd parallel-qrng
jupyter notebook
```

Once Jupyter starts, open the `ParallelQrng.ipynb` notebook and follow the instructions there.

## Q# with a Python host program

Make sure that you have followed the [Q# + Python quickstart](https://docs.microsoft.com/azure/quantum/install-python-qdk) for the Quantum Development Kit, and then run Python from within the folder containing this sample.

The Python host program takes as command-line arguments the resource, location, and target IDs to submit your Azure Quantum service job to.
When running the command below, make sure to replace the example resource ID with the ID for your workspace, replace `LOCATION` with the location for your workspace, and replace `TARGET_ID` with the target that you would like to submit to (e.g.: `ionq.simulator`). The information for resource ID, location, and available targets can be found in the Azure Portal.

```shell
cd parallel-qrng/python-host
python parallel_qrng.py /subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME/providers/Microsoft.Quantum/Workspaces/WORKSPACE_NAME LOCATION TARGET_ID
```

For a full list of available quantum computing targets, run:

```azcli
az quantum target list --output table
```

> :warning:
> This sample makes use of paid services on Azure Quantum. The cost of running this sample *with the provided parameters* on IonQ in a Pay-As-You-Go subscription is approximately $1-$2 USD (or the equivalent amount in your local currency). This quantity is only an approximate estimate and should not be used as a binding reference. The cost of the service might vary depending on your region, demand and other factors.

## Manifest

- [ParallelQrng.csproj](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/parallel-qrng/ParallelQrng.csproj): Main Q# project file for this sample.
- [ParallelQrng.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/parallel-qrng/ParallelQrng.qs): Main Q# program for this sample.
- [ParallelQrng.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/parallel-qrng/ParallelQrng.ipynb): IQ# notebook for this sample.
- [parallel_qrng.py](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/parallel-qrng/parallel_qrng.py): Host program for running this sample from Python.
