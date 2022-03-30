---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates using Q# and Python together to perform quantum process tomography."
urlFragment: qsharp-with-python
---

# Randomized benchmarking with online adaptive heuristic

This sample demonstrates using Q# to run a randomized benchmarking experiment with an online heuristic for choosing sequence lengths. In particular, this sample uses a statistical inference algorithm written in Q# to choose randomized benchmarking sequences so as to maximize how much we learn about the fidelity of a gateset with each sequence.

> **NOTE**: This sample is somewhat more advanced than most, and assumes familiarity with open quantum systems as well as some statistics knowledge.
> If you would like a refresher on these topics, please check out the [**process-tomography**](../process-tomography/README.md) and [**phase-estimation**](../phase-estimation/README.md) samples.

## Installation

As this sample demonstrates using Q# and Python together, make sure you have the `qsharp` package for Python installed first; see the [Getting Started with Python](https://docs.microsoft.com/azure/quantum/install-python-qdk) guide for details.

This sample also uses a couple extra Python packages to help out, so you'll need to have those ready as well.
If you are using the [**Anaconda distribution**](https://www.anaconda.com/) of Python, this can be done automatically by using the `environment.yml` file provided with this sample:

```shell
cd samples/characterization/randomized-benchmarking
conda env create -f environment.yml
conda activate randomized-benchmarking
```

### Running the Sample

Once everything is installed, run `jupyter notebook` to start the Jupyter Notebook interface in your web browser:

```shell
jupyter notebook
```

In the browser, select the `randomized-benchmarking.ipynb` notebook in your browser to
view the sample.

## Manifest

- [randomized-benchmarking.ipynb](./randomized-benchmarking.ipynb): Jupyter Notebook demoing the randomized benchmarking protocol.
- [environment.yml](./environment.yml): Specification of a conda environment for use with randomized benchmarking.
- [Math.qs](./Math.qs): Special functions and linear algebra support for this sample.
- [Inference.qs](./Inference.qs): Implementation of the particle filtering algorithm for Q#.
