# Adiabatic Ising Evolution Sample #

This sample converts a representation of a Hamiltonians using library data types into unitary time-evolution by the Hamiltonian on qubits. We consider the Ising model and study adiabatic state preparation of its ground state for the cases of uniform ferromagnetic and anti-ferromagnetic coupling between sites.

## Running the Sample ##

Open the `QsharpLibraries.sln` solution in Visual Studio and set the .csproj file in the manifest as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [AdiabaticIsing.qs](./AdiabaticIsing.qs): Q# code implementing quantum operations for this sample.
- [Program.cs](./Program.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [AdiabaticIsingSample.csproj](./AdiabaticIsingSample.csproj): Main C# project for the sample.

## Note ##

This sample builds on results in [IsingGenerators](./../IsingGenerators) sample.
We suggest reading that sample before continuing.