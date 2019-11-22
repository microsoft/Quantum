# Hamiltonian Simulation Samples #

These samples show how to simulate evolution under different Hamiltonians.

- *H₂ Simulation*
  - **[H2SimulationCmdLine](./h2/command-line)**:
      This sample walks through the simulation of molecular hydrogen using the Trotter–Suzuki decomposition.
  - **[H2SimulationGUI](./h2/gui)**:
      This sample builds on *H2SimulationCmdLine* by using the [Electron](https://electronjs.org/) framework and the [chart.js](http://www.chartjs.org/) package to plot results asynchronously in a cross-platform application.
- *Ising Model Simulation*
  - **[SimpleIsing](./ising/simple)**: This sample walks through constructing the time-evolution operator for the Ising model.
  - **[IsingGenerators](./ising/generators)**: This sample describes how Hamiltonians may be represented using Microsoft.Quantum.Canon functions.
  - **[AdiabaticIsing](./ising/adiabatic)**: This sample converts a representation of a Hamiltonian using library data types into unitary time-evolution by the Hamiltonian on qubits.
  - **[IsingPhaseEstimation](./ising/phase-estimation)**: This sample adiabatically prepares the ground state of the Ising model Hamiltonian, and then perform phase estimation to obtain an estimate of the ground state energy. 
  - **[IsingTrotterEvolution](./ising/trotter-evolution)**: This sample walks through constructing the time-evolution operator for the Ising model using the Trotterization library feature.
- **[HubbardSimulation](./hubbard)**: This sample walks through constructing the time-evolution operator for the 1D Hubbard Simulation model.
