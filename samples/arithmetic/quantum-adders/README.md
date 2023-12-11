---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample uses Q# to factor integers with Shor's algorithm."
urlFragment: quantum-adders
---

# Quantum adders

This sample shows how to add two integers using the arithmetic functionality in the Q# standard library.
Two examples of adders implemented in this sample are that of [Takahashi *et al.*](https://arxiv.org/abs/0910.2530) and [Cuccaro *et al.*](https://arxiv.org/abs/quant-ph/0410184).

## Running the Sample

To run this sample, you will need Jupyter Notebook and the IQ# kernel.
For instructions on how to set up these tools see the [getting started guide](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).
To start the Jupyter Notebook use the following command in this directory.

```shell
jupyter notebook AdderExample.ipynb
```

Use the `Run` button to walk through the notebook line by line.

## Manifest

- [AdderExample.ipynb](./AdderExample.ipynb): Jupyter Notebook with Q# code implementing a couple of quantum adders.
