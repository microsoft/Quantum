---
page_type: sample
author: guenp
description: Estimate the molecular ground state energy of hydrogen using the Azure Quantum service
ms.author: guenp@microsoft.com
ms.date: 05/18/2021
languages:
- qsharp
- python
products:
- qdk
- azure-quantum
---

# Simple molecular energy estimation with the Azure Quantum service

This sample demonstrates how to use Q#, Python and the Azure Quantum service together to estimate the ground state of a molecule, implemented as two Jupyter notebooks.

## Running the sample

To run the sample, first make sure to install all [prerequisites](https://docs.microsoft.com/azure/quantum/install-python-qdk) and start a Jupyter notebook with the following command:

```cmd
jupyter notebook
```

Open the notebooks ([QuantumPhaseEstimation/Molecule.ipynb](QuantumPhaseEstimation/Molecule.ipynb) or [Hamiltonian/Molecule.ipynb](Hamiltonian/Molecule.ipynb)) and execute the cells (shift + enter) to run the sample.

To run the second notebook, make sure to first create an Azure subscription and Azure Quantum workspace. Learn more about this here: [Introduction to Azure Quantum (preview)](https://docs.microsoft.com/en-us/azure/quantum/overview-azure-quantum).

## Manifest

- [QuantumPhaseEstimation/GetEnergyQPE.qs](QuantumPhaseEstimation/GetEnergyQPE.qs): Quantum Phase Estimation program.
- [QuantumPhaseEstimation/GetEnergyVQE.qs](QuantumPhaseEstimation/GetEnergyVQE.qs): Varational Quantum Eigensolver program.
- [QuantumPhaseEstimation/Molecule.csproj](QuantumPhaseEstimation/Molecule.csproj): Q# project file for this sample.
- [QuantumPhaseEstimation/Molecule.ipynb](QuantumPhaseEstimation/Molecule.ipynb): Jupyter notebook that runs simulation and resoure estimation for the above.
- [Hamiltonian/GetHamiltonianTerm.qs](Hamiltonian/GetHamiltonianTerm.qs): Program that estimates the energy for a single Hamiltonian term.
- [Hamiltonian/ChemUtils.qs](Hamiltonian/ChemUtils.qs): Utility functions for running the chemistry algorithm.
- [Hamiltonian/Molecule.csproj](Hamiltonian/Molecule.csproj): Q# project file for this sample.
- [Hamiltonian/Molecule.ipynb](Hamiltonian/Molecule.ipynb): Jupyter notebook that runs program on Azure Quantum via IonQ simulator and QPU.
- [data/broombridge/caffeine.yaml](data/broombridge/caffeine.yaml): Broombridge file for caffeine molecule
- [data/broombridge/HHO.yaml](data/broombridge/HHO.yaml): Broombridge file for HHO molecule
- [data/broombridge/hydrogen_0.2.yaml](data/broombridge/hydrogen_0.2.yaml): Broombridge file for hydrogen molecule
- [data/broombridge/pyridine.yaml](data/broombridge/pyridine.yaml): Broombridge file for pyridine molecule

- [data/xyz/bcarotine.xyz](data/xyz/bcarotine.xyz): XYZ (molecular geometry) file for bcarotine molecule
- [data/xyz/c2h410.xyz](data/xyz/c2h410.xyz): XYZ (molecular geometry) file for methane molecule
- [data/xyz/caffeine.xyz](data/xyz/caffeine.xyz): XYZ (molecular geometry) file for caffeine molecule
- [data/xyz/femoco.xyz](data/xyz/femoco.xyz): XYZ (molecular geometry) file for femoco molecule
- [data/xyz/h2.xyz](data/xyz/h2.xyz): XYZ (molecular geometry) file for hydrogen molecule
- [data/xyz/Pb3O4_vib.xyz](data/xyz/Pb3O4_vib.xyz): XYZ (molecular geometry) file for Pb3O4 molecule
- [data/xyz/pyridine.xyz](data/xyz/pyridine.xyz): XYZ (molecular geometry) file for pyridine molecule
