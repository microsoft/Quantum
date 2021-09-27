---
page_type: sample
languages:
- python
products:
- qdk
- azure-quantum
description: "This sample demonstrates how to use Honeywell and IonQ on the Azure Quantum service with quantum circuits expressed in various Python libraries."
urlFragment: azure-quantum-with-python-circuits
---

# Getting started with Python libraries on Azure Quantum

These sample notebooks demonstrate how to use the `azure-quantum` Python library to submit quantum circuits expressed with [Cirq](https://quantumai.google/cirq), [Qiskit](https://github.com/QISKit/qiskit-terra) and the provider-specific formats [OpenQASM 2.0](https://github.com/Qiskit/openqasm/tree/OpenQASM2.x) and [JSON](https://docs.ionq.com/#tag/quantum_programs) to an Azure Quantum Workspace.

## Installation

### Provider-specific formats

To install the `azure-quantum` package, run

```shell
pip install azure-quantum
```

To install the optional dependencies for the "Getting started with Cirq" notebooks, run

```shell
pip install azure-quantum[cirq]
```

To install the optional dependencies for the "Getting started with Qiskit" notebooks, run

```shell
pip install azure-quantum[qiskit]
```

To install all optional dependencies, run

```shell
pip install azure-quantum[cirq,qiskit]
```

### Running the Sample

Once everything is installed, run `jupyter notebook` to start the Jupyter Notebook interface in your web browser:

```shell
jupyter notebook
```

In the browser, select the desired sample notebook in your browser to view the code.

## Manifest

- [Getting-started-with-Cirq-and-Honeywell-on-Azure-Quantum.ipynb](./Getting-started-with-Cirq-and-Honeywell-on-Azure-Quantum.ipynb): Jupyter notebook for getting started with Cirq and Honeywell.
- [Getting-started-with-Cirq-and-IonQ-on-Azure-Quantum.ipynb](./Getting-started-with-Cirq-and-IonQ-on-Azure-Quantum.ipynb): Jupyter notebook for getting started with Cirq and IonQ.
- [Getting-started-with-Honeywell-and-OpenQASM-2.0-on-Azure-Quantum.ipynb](./Getting-started-with-Honeywell-and-OpenQASM-2.0-on-Azure-Quantum.ipynb): Jupyter notebook for getting started with OpenQASM 2.0 and Honeywell.
- [Getting-started-with-IonQ-and-JSON-on-Azure-Quantum.ipynb](./Getting-started-with-IonQ-and-JSON-on-Azure-Quantum.ipynb): Jupyter notebook for getting started with JSON and IonQ.
- [Getting-started-with-Qiskit-and-Honeywell-on-Azure-Quantum.ipynb](./Getting-started-with-Qiskit-and-Honeywell-on-Azure-Quantum.ipynb): Jupyter notebook for getting started with Qiskit and Honeywell.
- [Getting-started-with-Qiskit-and-IonQ-on-Azure-Quantum.ipynb](./Getting-started-with-Qiskit-and-IonQ-on-Azure-Quantum.ipynb): Jupyter notebook for getting started with Qiskit and IonQ.
