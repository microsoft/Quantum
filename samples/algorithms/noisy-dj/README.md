---
page_type: sample
languages:
- qsharp
- python
products:
- qdk
description: "This sample uses Q# and Python together to simulate noise in the Deutsch–Jozsa algorithm."
urlFragment: noisy-dj
---

# Deutsch–Jozsa algorithm with noise

This sample demonstrates:

- How to use Q# and Python together to write and simulate quantum algorithms.
- How to use the Quantum Development Kit to simulate noisy quantum devices.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).
- Jupyter Notebook
- The [QuTiP library](https://qutip.org) for Python

To install all required dependencies using the [Anaconda distribution](http://anaconda.com/):

```shell
conda install -c microsoft -c conda-forge notebook qsharp qutip
```

## Running the Sample

From the command line, start Jupyter Notebook:

```shell
jupyter notebook
```

## Manifest

- [Deutsch–Jozsa with Noise.ipynb](./Deutsch–Jozsa%20with%20Noise.ipynb): main Jupyter Notebook for this sample.
