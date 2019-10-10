# Hamiltonian Simulation Samples #

These samples show how to simulate evolution under different Hamiltonians.

- *H₂ Simulation*
  - **[H2SimulationCmdLine](./Samples/src/H2SimulationCmdLine)**:
      This sample walks through the simulation of molecular hydrogen using the Trotter–Suzuki decomposition.
  - **[H2SimulationGUI](./Samples/src/H2SimulationGUI)**:
      This sample builds on *H2SimulationCmdLine* by using the [Electron](https://electronjs.org/) framework and the [chart.js](http://www.chartjs.org/) package to plot results asynchronously in a cross-platform application.
- *Ising Model Simulation*
  - **[SimpleIsing](./Samples/src/SimpleIsing)**: This sample walks through constructing the time-evolution operator for the Ising model.
  - **[IsingGenerators](./Samples/src/IsingGenerators)**: This sample describes how Hamiltonians may be represented using Microsoft.Quantum.Canon functions.
  - **[AdiabaticIsing](./Samples/src/AdiabaticIsing)**: This sample converts a representation of a Hamiltonian using library data types into unitary time-evolution by the Hamiltonian on qubits.
  - **[IsingPhaseEstimation](./Samples/src/IsingPhaseEstimation)**: This sample adiabatically prepares the ground state of the Ising model Hamiltonian, and then perform phase estimation to obtain an estimate of the ground state energy. 
  - **[IsingTrotterEvolution](./Samples/src/IsingTrotterEvolution)**: This sample walks through constructing the time-evolution operator for the Ising model using the Trotterization library feature.
- **[HubbardSimulation](./Samples/src/HubbardSimulation)**: This sample walks through constructing the time-evolution operator for the 1D Hubbard Simulation model.
