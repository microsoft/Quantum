# Hubbard Simulation Sample #

This sample walks through constructing the time-evolution operator for the 1D Hubbard Simulation model. This time-evolution operator is applied to project onto the ground state of Hubbard Hamiltonian using phase estimation.

## Running the Sample ##

Open the `QsharpLibraries.sln` solution in Visual Studio and set the .csproj file in the manifest as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [HubbardSimulation.qs](./HubbardSimulation.qs): Q# code implementing quantum operations for this sample.
- [Program.cs](./Program.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [HubbardSimulationSample.csproj](./HubbardSimulationSample.csproj): Main C# project for the sample.