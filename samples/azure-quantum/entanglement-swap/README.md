---
page_type: sample
author: adrianleh
description: Entanglement swapping using the Azure Quantum service
ms.author: t-alehmann@microsoft.com
ms.date: 08/02/2021
languages:
- qsharp
- qiskit
- python
products:
- qdk
- azure-quantum
---

# Entanglement Swapping

In this sample, we will performing entanglement swapping.

The idea is that Alice and Bob want to use quantum teleportation to share data.
Though, they are too far apart to communicate directly.
Hence, they will be use a number of middlemen to communicate.
Each party will share an entangled pair with the parties next to them and teleport the information along the chain until it reaches Bob.
Since this sample is fundamentally based on teleportation we use Quantinuum's mid-circuit measurement capability.

This sample is a Q# and Qiskit Jupyter notebook targeted at Quantinuum machines.

## Q# with Jupyter Notebook

Make sure that you have followed the [Q# + Jupyter Notebook quickstart](https://docs.microsoft.com/azure/quantum/install-jupyter-qdk) for the Quantum Development Kit, and then start a new Jupyter Notebook session from the folder containing this sample:

```shell
cd entanglement-swapping
jupyter notebook
```

Once Jupyter starts, open the `ES-quantinuum-qsharp.ipynb` or `ES-quantinuum-qiskit.ipynb` notebook and follow the instructions there.

## Manifest

- [ES-quantinuum-qsharp.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/entanglement-swapping/ES-quantinuum-qsharp.ipynb): IQ# notebook for this sample targetting Quantinuum.
- [ES-quantinuum-qiskit.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/entanglement-swapping/ES-quantinuum-qiskit.ipynb): Qiskit notebook for this sample targetting Quantinuum.