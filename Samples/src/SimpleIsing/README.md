# Ising Simple Sample #

This sample walks through constructing the time-evolution operator for the Ising model manually.
This time-evolution operator is applied to adiabatically prepare the ground state of the Ising model.
The net magnetization is then measured.

## Running the Sample ##

Open the `QsharpLibraries.sln` solution in Visual Studio and set the .csproj file in the manifest as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [SimpleIsing.qs](./SimpleIsing.qs) : Q# code implementing quantum operations for this sample.
- [Program.cs](./Program.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [SimpleIsingSample.csproj](./SimpleIsingSample.csproj) : Main C# project for the sample.
