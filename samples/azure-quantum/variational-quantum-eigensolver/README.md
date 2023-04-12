---
page_type: sample
author: guenp
description: Variational Quantum Eigensolver
ms.author: guenp@microsoft.com
ms.date: 05/02/2022
languages:
- python
products:
- azure-quantum
---

# Estimating the ground state energy of hydrogen using variational quantum eigensolvers (VQE) on Azure Quantum

This sample shows how to estimate the ground state energy of hydrogen using the Azure Quantum service. In particular, this sample uses the implementation of the variational quantum eigensolver algorithm provided with Qiskit to estimate minimum energies. The sample demonstrates running this VQE implementation the simulator provided by IonQ and on the emulator provided by Quantinuum.

## Manifest

- [VQE-qiskit-hydrogen-ionq-sim.ipynb](./VQE-qiskit-hydrogen-ionq-sim.ipynb): Python + Qiskit notebook demonstrating using VQE on the IonQ simulator.
- [VQE-qiskit-hydrogen-quantinuum-emulator.ipynb](./VQE-qiskit-hydrogen-quantinuum-emulator.ipynb): Python + Qiskit notebook demonstrating using VQE on the Quantinuum emulator.
- [VQE-qiskit-hydrogen-session.ipynb](./VQE-qiskit-hydrogen-session.ipynb): Python + Qiskit notebook demonstrating using VQE on multiple backends using a session.

## See Also

To learn more about variational quantum eigensolvers, see the introduction at https://docs.microsoft.com/samples/microsoft/quantum/variational-quantum-algorithms/.
