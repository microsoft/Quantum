---
page_type: sample
author: adrianleh
description: Solves Sudoku Puzzle using Grover's Search, using the Azure Quantum service
ms.author: t-alehmann@microsoft.com
ms.date: 08/16/2021
languages:
- qsharp
- python
products:
- qdk
- azure-quantum
---

# Solving Sudoku with Grover's search

In this sample we will be solving the classic puzzle Sudoku using Grover's search.

We will be basing our algorithm off the [official sample on GitHub](https://github.com/microsoft/Quantum/tree/main/samples/algorithms/sudoku-grover).
In the following we will adapt the sample to run on actual hardware.
Given that quantum hardware is in its infancy right now, we need to minimize qubit count, circuit depth (think number of gates), and limit hybrid interactions.

Since Grover's search is fundamentally a quantum algorithm requiring classical preprocessing, we will use the feature of Q# notebooks integrating with python.
This will further enable us to have some convenience in the data structures we build, such as classical validation of Sudoku puzzles.

This sample is a Q# jupyter notebook targeted at IonQ and Quantinuum machines.

## Q# with Jupyter Notebook

Make sure that you have followed the [Q# + Jupyter Notebook quickstart](https://docs.microsoft.com/azure/quantum/install-jupyter-qdk) for the Quantum Development Kit, and then start a new Jupyter Notebook session from the folder containing this sample:

```shell
cd grover-sudoku
jupyter notebook
```

Once Jupyter starts, open the `Grovers-sudoku-quantinuum.ipynb` notebook and follow the instructions there.

## Manifest

- [Grovers-sudoku-quantinuum.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/grover-sudoku/Grovers-sudoku-quantinuum.ipynb): IQ# notebook for this sample targetting Quantinuum.
