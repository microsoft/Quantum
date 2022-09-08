---
page_type: sample
author: adrianleh
description: Solving Sudoku with Grover's search, using the Azure Quantum service
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

In this sample, we will be solving Sudoku puzzles using Grover's search.

Given that we will run our algorithm on current quantum hardware, we need to minimize qubit count and circuit depth (number of gates) required by the algorithm.

Since Grover's search is fundamentally a quantum algorithm requiring classical preprocessing, we will use the feature of Python notebooks integrating with Q#.
This will further enable us to have some convenience in the data structures we build, such as classical validation of Sudoku puzzles.

## Q# with Jupyter Notebook

Make sure that you have followed the [Q# + Jupyter Notebook quickstart](https://docs.microsoft.com/azure/quantum/install-jupyter-qdk) for the Quantum Development Kit, and then start a new Jupyter Notebook session from the folder containing this sample:

```shell
cd grover-sudoku
jupyter notebook
```

Once Jupyter starts, open the `Grovers-sudoku-quantinuum.ipynb` notebook and follow the instructions there.

## Manifest

- [GroversSudokuQuantinuum.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/grover-sudoku/Grovers-sudoku-quantinuum.ipynb): IQ# notebook for this sample targetting Quantinuum.
