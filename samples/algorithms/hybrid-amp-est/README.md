---
page_type: sample
author: aameenak, wimvandam
description: Search unstructured data with a hybrid quantum-classical algorithm on noisy systems using Azure Quantum service
ms.author: aarthi.sundaram@microsoft.com. wimvandam@microsoft.com
ms.date: 02/03/2023
languages:
- python
- qsharp
products:
- qdk
- azure-quantum
---

# Quantum-classical Amplitude estimation

This sample demonstrates a quantum-classical hybrid approach to perform amplitude estimation using Maximum Likelihood Estimation assuming that depolarizing noise acts on the qubits. Specifically, this Azure Quantum notebook implements a noisy version of the Power Law Amplitude Estimation algorithm from [[Tiron et al.]](https://arxiv.org/abs/2012.03348v1) and uses both Python and Q# for this hybrid approach. Currently, it runs on the quantum simulator and not on hardware.

The sample can be run in two different ways:

- Azure Quantum service
- Python + Q# with Jupyter Notebook

## Running the sample on the Azure Quantum service

Make sure that you have [created and selected a quantum workspace](https://docs.microsoft.com/azure/quantum/how-to-create-quantum-workspaces-with-the-azure-portal). Then upload the notebook `NoisyPowerLawAmpEst.ipynb` into the `My Notebooks` section and follow the instructions.

## Running the sample locally with Jupyter Notebook

Make sure that you have followed the [Q# + Python environment quickstart](https://learn.microsoft.com/en-us/azure/quantum/install-python-qdk?source=recommendations&tabs=tabid-conda) for the Quantum Development Kit, and then start a new Jupyter Notebook session from the folder containing this sample:

```shell
cd hybrid-amp-est
jupyter notebook
```

Once Jupyter starts, open the `NoisyPowerLawAmpEst.ipynb` notebook and follow the instructions there.

## Manifest

- [NoisyPowerLawAmpEst.ipynb](./PowerLawAmpEst.ipynb): Python + Q# notebook for this sample.

## References

To learn more about hybrid approaches to amplitude estimation see:

- [[Tiron et al.]](https://arxiv.org/abs/2012.03348v1): Tudor Giurgica-Tiron, Iordanis Kerenidis, Farrokh Labib, Anupam Prakash, and William Zeng (2022), "Low depth algorithms for quantum amplitude estimation", _Quantum,_ Volume 6, pp. 745;  arXiv:2012.03348
