---
page_type: sample
languages:
- python
products:
- qdk
- azure-quantum
description: "This sample demonstrates how to use Quantinuum and IonQ via the Azure Quantum service with quantum circuits expressed with Qiskit."
urlFragment: azure-quantum-with-python-circuits
---

# Getting started submitting quantum circuits with Qiskit

These sample notebooks demonstrate how to use the `azure-quantum` Python library to submit quantum circuits expressed with [Qiskit](https://github.com/QISKit/qiskit-terra) to an Azure Quantum Workspace.

## Installation

### Provider-specific formats

To install the `azure-quantum` package, run

To install the optional dependencies for the "Getting started with Qiskit" notebooks, run

```shell
pip install azure-quantum[qiskit]
```

### Running the Sample

Once everything is installed, run `jupyter notebook` to start the Jupyter Notebook interface in your web browser:

```shell
jupyter notebook
```

In the browser, select the desired sample notebook to view the code.

## Manifest

- [Getting-started-with-Qiskit-and-Quantinuum-on-Azure-Quantum.ipynb](./Getting-started-with-Qiskit-and-Quantinuum-on-Azure-Quantum.ipynb): Jupyter notebook for getting started with Qiskit and Quantinuum.
- [Getting-started-with-Qiskit-and-IonQ-on-Azure-Quantum.ipynb](./Getting-started-with-Qiskit-and-IonQ-on-Azure-Quantum.ipynb): Jupyter notebook for getting started with Qiskit and IonQ.
