# Quantum Chemistry Library Samples #

These samples demonstrate the use of the Quantum Chemistry library.
Each sample is provided as a Visual Studio 2019 C# or project in their respective directories.
Each of these samples are described below.
Most of the samples consist of a Q# source file with detailed comments explaining the sample and a commented classical program `Program.cs` to call into Q# operations and functions.

## How to Run the C# Samples ##

All the C# samples may be run with default settings by entering their root directory in command line and entering `dotnet run`.

These samples focus on simple models in chemistry and material sciences. They are thoroughly commented to build familiarity with usage of the chemistry library.

- **[CreateHubbardHamiltonian](CreateHubbardHamiltonian/)**:
  Construct a Hamiltonian describing a simple one-dimensional Hubbard model.

- **[SimulateHubbardHamiltonian](SimulateHubbardHamiltonian/)**:
  Import the Hubbard Hamiltonian constructed in [CreateHubbardHamiltonian](CreateHubbardHamiltonian/), and obtain estimates of its energy levels by simulating the quantum phase estimation algorithm.

- **[MolecularHydrogen](MolecularHydrogen/)**:
  Construct a Hamiltonian describing the Hydrogen molecule, and obtain estimates of its energy levels by simulating the quantum phase estimation algorithm.

- **[MolecularHydrogenGUI](MolecularHydrogenGUI/)**:
  Import the Q# operations for energy estimation in [MolecularHydrogen](MolecularHydrogen/) to create a plot of Hydrogen ground state energy with respect to distance between its two Hydrogen atoms.

- **[LithiumHydrideGUI](LithiumHydrideGUI/)**:
  Import the Q# operations for energy estimation in [MolecularHydrogen](MolecularHydrogen/) to create a plot of Lithium Hyride ground state and excited energies with respect to distance between its atoms.


### General Samples ###

These advanced samples target arbitrary chemistry or material science models that are loaded from a file.

- **[AnalyzeHamiltonian](AnalyzeHamiltonian/)**:
  Loads a spin-orbital Hamiltonian from a file containing orbital integrals. Features of the Hamiltonian are then computed. Currently, only the L1-norm of the coefficients is computed.

- **[GetGateCount](GetGateCount/)**:
  Loads a spin-orbital Hamiltonian from a file containing orbital integrals. A resource estimate for running a single Trotter step or Qubitization step is then executed. Optional integration with PowerShell is also demonstrated.

- **[RunSimulation](RunSimulation)**:
  Loads a spin-orbital Hamiltonian from a file containing orbital integrals. A full quantum simulation of phase estimation is then run on a quantum simulation of the Hamiltonian. An estimate of an energy eigenstate is then returned. Note that the probability of returning the lowest energy state depends on the overlap of the initial state with the true ground state.

## Python Samples ##

These samples show how to use Q# chemistry library from Python to load Broombridge schema files
and run a simulation to obtain estimates of its energy levels.

- **[PythonIntegration](PythonIntegration/)**:
  Basic sample on how to integrate Q# with Python.
