---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates using Q# and Python together to perform gateset tomography."
urlFragment: gateset-tomography-with-qsharp
---

# Quantum process tomography

This sample demonstrates using Python and Q# together to run gateset tomography

## Installation

As this sample demonstrates using Q# and Python together, make sure you have the `qsharp` package for Python installed first; see the [Getting Started with Python](https://docs.microsoft.com/azure/quantum/install-python-qdk) guide for details.

This sample also uses a couple extra Python packages to help out, so you'll need to have those ready as well.
If you are using the [**Anaconda distribution**](https://www.anaconda.com/) of Python, this can be done automatically by using the `environment.yml` file provided with this sample:

```shell
cd samples/characterization/gateset-tomography
conda env create -f environment.yml
conda activate qsharp-gst
```

### Running the Sample

Once everything is installed, run `jupyter notebook` to start the Jupyter Notebook interface in your web browser:

```shell
jupyter notebook
```

In the browser, select the `gateset-tomography.ipynb` notebook in your browser to
view the sample.

## Manifest

- [gateset-tomography.ipynb](./gateset-tomography.ipynb): Main Jupyter Notebook for this sample.
- [environment.yml](./environment.yml): Specification of a conda environment for use with this sample.
