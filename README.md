# Quantum Development Kit Samples #

These samples demonstrate the use of the Quantum Development Kit for a variety of different quantum computing tasks.
Each sample is provided as a Visual Studio 2017 C# or F# project under the [`QsharpSamples.sln`](./Samples/QsharpSamples.sln) solution.
The samples are broken down into four broad categories, each of which is described below.
Most of the samples consist of a Q# source file with detailed comments explaining the sample and a short classical program (either `Program.cs` or `Program.fs`) to call into Q# operations and functions.

A small number of the samples have additional installation requirements beyond those for the rest of the Quantum Development Kit.
These are noted in the README.md files for each sample, along with complete installation instructions.

## 0. Introductory Samples ##

- **[TeleportationSample](./Samples/src/Teleportation/)**:
  This sample documents how to write quantum programs with Q#, C#, and Visual Studio, using the [development techniques](https://docs.microsoft.com/quantum/quantum-devguide-1-intro) covered in the main documentation.
- **[Measurement](./Samples/src/Measurement)**:
  This sample goes into more detail about how single- and multiple-qubit measurements are represented in Q#, and how to measure in interesting bases such as the Bell basis.
- **[SimpleAlgorithms](./Samples/src/SimpleAlgorithms)**:
  This sample covers several different basic quantum algorithms, and how each can be written in Q#.

## 1. Algorithm Samples ##

- **[DatabaseSearch](./Samples/src/DatabaseSearch)**:
  This sample demonstrates how to use Grover's algorithm to efficiently search a database represented as a quantum register.
- **[IntegerFactorization](./Samples/src/IntegerFactorization)**:
  This sample demonstrates how to use Shor's algorithm to efficiently factor integers.
- **[ReversibleLogicSynthesis](./Samples/src/ReversibleLogicSynthesis)**:
  This sample demonstrates how to use reversible logic synthesis to solve the hidden shift problem.
- **[CHSHGame](./Samples/src/CHSHGame)**:
  This sample demonstrates a famous nonlocal game which proves that no theory of local hidden variables can ever reproduce all the predictions of quantum mechanics.

## 2. Characterization and Testing Samples ##

- **[UnitTesting](./Samples/src/UnitTesting)**:
  This sample demonstrates how to use the Quantum Development Kit together with the [xUnit](https://xunit.github.io/) framework to check the correctness of quantum programs by testing the correctness and computing the metrics of various small quantum circuits.
- **[BitFlipCode](./Samples/src/BitFlipCode)**:
  This sample shows how to use a simple quantum error correcting code to protect against errors in a quantum device.
- **[PhaseEstimation](./Samples/src/PhaseEstimation)**:
  This sample introduces iterative phase estimation, an important statistical problem in analyzing the output of quantum programs.

## 3. Hamiltonian Simulation Samples ##

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

## 4. Interoperability ##

- **[PythonInterop](./Samples/src/PythonInterop)** (Windows-only preview):
  This sample walks through using Python to perform quantum process tomography on an operation written in Q#.
 
## 5. Qasm (Quantum Assembler Language) ##

- **[OpenQasm](./Samples/src/OpenQasm)**:
  This sample shows that one can output the a subset of the quantum operations of a Q# application in OpenQASM.
- **[Qiskit](./Samples/src/Qiskit)**:
  This sample shows that one can run the quantum operations of a Q# application by using the OpenQASM output on the IBMQuantumExperience by changing the driver.
- **[OpenQasmReader](./Samples/src/OpenQasmReader)**:
  This sample shows that one can convert OpenQasm 2.0 specifications to Q# methods. This allows one to import algorithms written in OpenQasm 2.0 to be used on the Microsoft Q# Simulator. Appart of the barrier gate (which has no meaning in Q#) all gates are converted to Q# constructions.

## 6. QDK Docker container ##
You can build and use the [Docker image](./DockerImages) with a minimum installation of the QDK.
Jupyter is installed in the image. Run the container with the port exposed `-p 8888:8888` then run jupyter with
```$ jupyter notebook --no-browser --allow-root --ip=0.0.0.0```
in the container, then on the host you can access the notebook by going to the URL that Jupyter prints when it starts up. **Don't use this on the open internet** because the Jupyter server is run as root.

