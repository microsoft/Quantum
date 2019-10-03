﻿# Microsoft Quantum Development Kit Samples #
 [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/Microsoft/Quantum/master)

These samples demonstrate the use of the Quantum Development Kit for a variety of different quantum computing tasks.
Most samples are provided as a Visual Studio 2017 C# or F# project under the [`QsharpSamples.sln`](./Samples/QsharpSamples.sln) solution.

Each sample is self-contained in a folder. Most of the samples consist of a Q# source file with detailed comments explaining the sample and a short classical program (either `Program.cs` (C#), `Program.fs` (F#), or `host.py` (Python)) that calls into the Q# operations and functions. 
There are some samples that are written as an interactive Jupyter notebook thus require no classical host.

A small number of the samples have additional installation requirements beyond those for the rest of the Quantum Development Kit.
These are noted in the README.md files for each sample, along with complete installation instructions.

You can find instructions on how to install the Quantum Development Kit in [our online documentation](https://docs.microsoft.com/en-us/quantum/install-guide/), which also includes
an introduction to [quantum programming concepts](https://docs.microsoft.com/en-us/quantum/concepts/). A [Docker](https://docs.docker.com/install/) image definition is also provided for your convenience, see below
for instructions on how to build and use it.

The samples are broken down into four broad categories, each of which is described below.

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

## Docker image

You can use the included [Dockerfile](./Dockerfile) to create a docker image 
with all the necessary libraries to use the Quantum Development Kit to build
quantum applications in C#, Python or Jupyter.

Once you have installed [Docker](https://docs.docker.com/install/), you can
use the following commands to get you started:

To build the docker image and tag it `iqsharp`:
```sh
docker build -t iqsharp .
```

To run the image in the container named `iqsharp-container` with interactive command-line and 
redirect container port 8888 to local port 8888 (needed to run jupyter):
```sh
docker run -it --name iqsharp-container -p 8888:8888 iqsharp /bin/bash
```

From the corresponding container command line, you can run the C# version of the Teleportation sample using: 
```sh
cd ~/Samples/src/Teleportation && dotnet run
```

Similarly, you can run the Python version of the Teleportation sample using: 
```sh
cd ~/Samples/src/Teleportation && python host.py
```

Finally, to start jupyter notebook within the image for the Teleportation sample, use:
```sh
cd ~/Samples/src/Teleportation && jupyter notebook --ip=0.0.0.0 --no-browser 
```

Once Jupyter has started, you can open in your browser the Teleportation notebook (you
will need a token generated by jupyter when it started on the previous step):

> http://localhost:8888/notebooks/Notebook.ipynb

Once you're done, to remove container named `iqsharp-container`:
```sh
docker rm --force iqsharp-container
```
