---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates how to use Q# and Python together."
urlFragment: qsharp-with-python
---

# Python Interoperability

This sample demonstrates the use of Python to call into Q# by using the [QInfer](http://qinfer.org/) and [QuTiP](http://qutip.org/).

## Installation

As this sample demonstrates using Q# and Python together, make sure you have the `qsharp` package for Python installed first; see the [Getting Started with Python](https://docs.microsoft.com/azure/quantum/install-python-qdk) guide for details.

If you are using the [**Anaconda distribution**](https://www.anaconda.com/) of Python, this can be done automatically by using the `environment.yml` file provided with this sample:

```shell
cd samples/interoperability/python
conda env create -f environment.yml
conda activate python-qsharp
```

### Running the Sample

Once everything is installed, run `jupyter notebook` to start the Jupyter Notebook interface in your web browser:

```shell
jupyter notebook
```

In the browser, select the `python-qsharp-interop.ipynb` notebook in your browser to
view the sample.

## Manifest

- [Operations.qs](./Operations.qs): Q# code that is loaded by the Jupyter Notebook.
- [python-qsharp-interop.ipynb](./tomography-sample.ipynb): Jupyter Notebook demoing the Python interoperability with Q#.
- [environment.yml](./environment.yml): Specification of a conda environment for use with Q# interoperability samples.

```python

```
