---
page_type: sample
author: cesarzc
description: Create a 3 qubit repetition code to detect and correct bit flip errors using integrated hybrid computing features.
ms.author: cesarzc@microsoft.com
ms.date: 03/01/2023
languages:
- qsharp
products:
- qdk
- azure-quantum
---

# Three Qubit Repetition Code

This sample demonstrates how to create a 3 qubit repetition code that can be used to detect and correct bit flip errors.

It leverages integrated hybrid computing features to count the number of times a bit flip error occurred while the state of a qubit register is coherent.

## Manifest

- [TQRP-quantinuum-qsharp.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/three-qubit-repetition-code/TQRP-quantinuum-qsharp.ipynb): Azure Quantum notebook for running a 3-qubit repetition code on the Quantinuum simulator
- [TQRP-qci-qsharp.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/three-qubit-repetition-code/TQRP-qci-qsharp.ipynb): Azure Quantum notebook for running a 3-qubit repetition code on the QCI simulator