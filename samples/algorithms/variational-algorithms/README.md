---
page_type: sample
languages:
- qsharp
- python
products:
- qdk
description: "This sample demonstrates how to use Q# to write variational quantum algorithms."
urlFragment: variational-quantum-algorithms
---

# Implementing variational quantum algorithms in Q\#

This sample demonstrates:

- How variational quantum algorithms use classical and quantum computation together to solve problems.
- How to use Q# and QuTiP together to estimate the energy of different quantum states.
- Using Q# to implement the variational quantum eigensolver.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

This sample is designed to work with the conda environment specified by [`environment.yml`](./environment.yml). To create this environment:

```shell
conda env create -f environment.yml
```

## Running the Sample

This sample can be run as a Jupyter Notebook:

```shell
conda activate variational
jupyter notebook
```

## Manifest

- [Variational Quantum Algorithms.ipynb](./Variational%20Quantum%20Algorithms.ipynb): Main Jupyter Notebook for this sample.
- [Optimization.qs](./Optimization.qs): Q# implementation of the SPSA algorithm.
- [VariationalAlgorithms.csproj](./VariationalAlgorithms.csproj): Main Q# project for this sample.
- [enviornment.yml](./environment.yml): Specification of a conda environment for this sample.
- [.iqsharp-config.json](./.iqsharp-config.json): Preferences for Q# visualization in Jupyter Notebooks.

## References

- [arXiv:1304.3061](https://arxiv.org/abs/1304.3061v1)

## Further resources

- For an example of using variational quantum eigensolvers in chemistry, see [the **azure-quantum/chemistry** sample](../../azure-quantum/chemistry/README.md).
- For an example of using iterative phase estimation to more efficiently learn energies, see [the **characterization/phase-estimation** sample](../characterization/phase-estimation/BayesianPhaseEstimation.qs).
