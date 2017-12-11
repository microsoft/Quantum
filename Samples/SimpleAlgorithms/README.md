# Simple Quantum Algorithms Sample #

This sample describes three simple quantum algorithms: the Bernstein-Vazirani quantum algorithm to learn a parity function, the Deutsch-Jozsa quantum algorithm to distinguish constant Boolean functions from balanced ones, and the hidden shift quantum algorithm that identifies a shift pattern between so-called bent functions. 

## Running the Sample ##

Open the `QsharpLibraries.sln` solution in Visual Studio and set the .csproj file in the manifest as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [SimpleAlgorithms.qs](./SimpleAlgorithms.qs): Q# code implementing quantum operations for this sample.
- [Driver.cs](./Driver.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [SimpleAlgorithms.csproj](./SimpleAlgorithms.csproj): Main C# project for the sample.

