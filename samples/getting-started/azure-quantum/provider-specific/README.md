---
page_type: sample
languages:
- python
products:
- qdk
- azure-quantum
description: "This sample demonstrates how to use Quantinuum and IonQ via the Azure Quantum service with quantum circuits expressed with provider-specific formats OpenQASM 2.0 (Quantinuum) and JSON (IonQ)."
urlFragment: azure-quantum-with-qiskit
---

# Getting started submitting quantum circuits with provider-specific formats

These sample notebooks demonstrate how to use the `azure-quantum` Python library to submit quantum circuits expressed with the provider-specific formats [OpenQASM 2.0](https://github.com/Qiskit/openqasm/tree/OpenQASM2.x) and [JSON](https://docs.ionq.com/#tag/quantum_programs) to an Azure Quantum Workspace.

## Installation

### Provider-specific formats

To install the `azure-quantum` package, run

```shell
pip install azure-quantum
```

### Running the Sample

Once everything is installed, run `jupyter notebook` to start the Jupyter Notebook interface in your web browser:

```shell
jupyter notebook
```

In the browser, select the desired sample notebook to view the code.

## Manifest

- [Getting-started-with-Quantinuum-and-OpenQASM-2.0-on-Azure-Quantum.ipynb](./Getting-started-with-Quantinuum-and-OpenQASM-2.0-on-Azure-Quantum.ipynb): Jupyter notebook for getting started with OpenQASM 2.0 and Quantinuum.
- [Getting-started-with-IonQ-and-JSON-on-Azure-Quantum.ipynb](./Getting-started-with-IonQ-and-JSON-on-Azure-Quantum.ipynb): Jupyter notebook for getting started with JSON and IonQ.
