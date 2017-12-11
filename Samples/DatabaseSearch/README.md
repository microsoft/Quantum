# Database Search Sample #

This sample walks through Grover's search algorithm. Oracles implementing the database are explicitly constructed together with all steps of the algorithm. This features two examples -- the first implements the steps of Grover's algorithm manually. The second applies amplitude amplification functions in the canon to automate many steps of the implementation.

## Running the Sample ##

Open the `QsharpLibraries.sln` solution in Visual Studio and set the .csproj file in the manifest as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [DatabaseSearch.qs](./DatabaseSearch.qs): Q# code implementing quantum operations for this sample.
- [Program.cs](./Program.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [DatabaseSearchSample.csproj](./DatabaseSearchSample.csproj): Main C# project for the sample.
