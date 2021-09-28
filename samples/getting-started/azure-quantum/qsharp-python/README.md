---
page_type: sample
author: cgranade
description: Get started using Python to submit Q# programs to the Azure Quantum service
ms.author: chgranad@microsoft.com
ms.date: 09/27/2021
languages:
- qsharp
- python
products:
- qdk
- azure-quantum
---

# Get started using Python to submit Q# programs to the Azure Quantum service

This sample demonstrates how to use Python, Q# and the Azure Quantum service together to build a quantum random number generator (QRNG).
In particular, this sample uses a register of qubits rather than a single qubit to draw random numbers several bits at a time, avoiding the need for intermediate measurement.

## Q# with a Python host program

Make sure that you have followed the [Q# + Python quickstart](https://docs.microsoft.com/azure/quantum/install-python-qdk) for the Quantum Development Kit, and then run Python from within the folder containing this sample.

The Python host program takes as command-line arguments the resource and target IDs to submit your Azure Quantum service job to.
When running the command below, make sure to replace the example resource ID with the ID for your workspace, as listed in the Azure Portal, and to replace `TARGET_ID` with the target that you would like to submit to (e.g.: `ionq.simulator`).

```shell
cd parallel-qrng/python-host
python parallel_qrng.py /subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME/providers/Microsoft.Quantum/Workspaces/WORKSPACE_NAME TARGET_ID
```

For a full list of available QIO and quantum computing targets, run:

```azcli
az quantum target list --output table
```

> :warning:
> This sample makes use of paid services on Azure Quantum. The cost of running this sample *with the provided parameters* on IonQ in a Pay-As-You-Go subscription is approximately $1-$2 USD (or the equivalent amount in your local currency). This quantity is only an approximate estimate and should not be used as a binding reference. The cost of the service might vary depending on your region, demand and other factors.

## Manifest

- [ParallelQrng.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/parallel-qrng/ParallelQrng.ipynb): Main Python notebook for this sample.
