# Hamiltonian Simulation of H₂ : GUI #

This Sample demonstrates the use of the Quantum Development Kit for Hamiltonian simulation by showing how to simulate molecular hydrogen (H₂).
The sample walks through both simulating H₂ manually, and using the generator representation library provided in the canon.

## Running the Sample ##

Open the `QsharpLibraries.sln` solution in Visual Studio and set `Samples/H2SimulationGUI/H2SimulationSample.fsproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [Program.fs](./Program.fs): F# code to interact with the Hamiltonian simulation operations provided in the canon and to plot the results.
- [H2SimulationSample.fsproj](./H2SimulationSample.fsproj): Main F# project for the Sample.

Note that this sample depends on the [H2SimulationCmdLine](./../H2SimulationCmdLine) sample and executes operations defined in [Operation.qs](./../H2SimulationCmdLine/Operation.qs).

## Theory ##

The F# program provided with this sample compares the results of the simulation to exactly diagonalizing the Hamiltonian for each bond length.

## References ##

- O'Malley et. al. https://arxiv.org/abs/1512.06860
