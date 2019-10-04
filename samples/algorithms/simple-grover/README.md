# Grover Search Sample #

This sample implements Grover's search algorithm. Oracles implementing the database are explicitly constructed
together with all steps of the algorithm. See the [DatabaseSearch](../DatabaseSearch/README.md) sample for and
extended version and the [Grover Search Kata](https://github.com/microsoft/QuantumKatas/tree/master/GroversAlgorithm)
to learn more about Grover's algorithm and how to implement it in Q#.

## Running the Sample in Visual Studio ##

Open the `QsharpSamples.sln` solution in Visual Studio and set the .csproj file in the manifest as the startup project.
Press Start in Visual Studio to run the sample.

## Running the Sample from the Command Line ##
This sample can also be run from the command line, including from the integrated terminal in Visual Studio Code.
To run the C# host program for this sample, use the `dotnet` command:
```bash
dotnet run
```
To run this sample from Python:
```bash
python host.py
```

## Manifest ##

- [SimpleGrover.qs](./SimpleGrover.qs): Q# code implementing quantum operations for this sample.
- [Program.cs](./Program.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [SimpleGroverSample.csproj](./SimpleGroverSample.csproj): Main C# project for the sample.
