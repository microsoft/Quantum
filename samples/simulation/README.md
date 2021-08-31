# Hamiltonian Simulation Samples

These samples show how to simulate evolution under different Hamiltonians.

- *H₂ Simulation*
  - **[H2SimulationCmdLine](./h2/command-line)**:
      This sample walks through the simulation of molecular hydrogen using the Trotter–Suzuki decomposition.
  - **[H2SimulationGUI](./h2/gui)**:
      This sample builds on *H2SimulationCmdLine* by using the [Electron](https://electronjs.org/) framework and the [chart.js](http://www.chartjs.org/) package to plot results asynchronously in a cross-platform application.
- **[Ising Model Simulation](./ising)**: These samples demonstrate how to use Q# to simulate the Ising model.
- **[HubbardSimulation](./hubbard)**: This sample walks through constructing the time-evolution operator for the 1D Hubbard Simulation model.
- **[GaussianInitialState](./gaussian-initial-state)**: This sample walks through how to use Q# to prepare a register of qubits into a Gaussian wavefunction.
