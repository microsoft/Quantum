---
page_type: sample
languages:
- qsharp
- csharp
products:
- qdk
description: "This sample demonstrates using Q# and C# together to emulate permutation oracles in quantum algorithms."
urlFragment: oracle-emulation
---

# Oracle Emulation Sample

This sample describes how to create and use emulated permutation oracles with the full state simulator of the Quantum Development Kit. Emulated oracles directly permute the wavefunction in the simulator. They allow for rapid prototyping and testing of quantum algorithms that involve calls to classical functions on a superposition of input arguments. An important use case are arithmetic operations on quantum registers. Emulation is not applicable to quantum hardware and hence specific to the quantum simulator.

See [Häner et al., High Performance Emulation of Quantum Circuits (2016)](https://arxiv.org/abs/1604.06460) for a general explanation of oracle emulation.

## Running the Sample

Open the `QsharpSamples.sln` solution in Visual Studio and set the .csproj file in the manifest as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest

- [Operations.qs](./Operations.qs): The main Q# example code implementing quantum operations for this sample.
- [Driver.cs](./Driver.cs): C# code to interact with and print out results of the Q# operations for this sample. Also contains two examples for creating an oracle from a C# function.
- [PermutationOracle.cs](./PermutationOracle.cs): An extension of the QDK's quantum simulator with convenience functions to create and apply emulated oracles.
- [PermutationOracle.qs](./PermutationOracle.qs): The Q# interface for permutation oracles that can be emulated.
- [OracleEmulation.csproj](./OracleEmulation.csproj): Main C# project for the sample.
