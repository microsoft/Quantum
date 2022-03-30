---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates using Q# and Python together to perform quantum process tomography."
urlFragment: qsharp-with-python
---

# Quantum process tomography

This sample demonstrates the use of Python to call into Q# by using the [QInfer](http://qinfer.org/) and [QuTiP](http://qutip.org/) Python libraries to study the behavior of a Q# operation.

## Installation

As this sample demonstrates using Q# and Python together, make sure you have the `qsharp` package for Python installed first; see the [Getting Started with Python](https://docs.microsoft.com/azure/quantum/install-python-qdk) guide for details.

This sample also uses a couple extra Python packages to help out, so you'll need to have those ready as well.
If you are using the [**Anaconda distribution**](https://www.anaconda.com/) of Python, this can be done automatically by using the `environment.yml` file provided with this sample:

```shell
cd samples/characterization/process-tomography
conda env create -f environment.yml
conda activate process-tomography
```

### Running the Sample

Once everything is installed, run `jupyter notebook` to start the Jupyter Notebook interface in your web browser:

```shell
jupyter notebook
```

In the browser, select the `tomography-sample.ipynb` notebook in your browser to
view the sample.

## Manifest

- [tomography-sample.ipynb](./tomography-sample.ipynb): Jupyter Notebook demoing the Python interoperability with Q#.
- [environment.yml](./environment.yml): Specification of a conda environment for use with Q# interoperability samples.
