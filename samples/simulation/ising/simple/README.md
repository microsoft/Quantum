# Ising Simple Sample #

This sample walks through constructing the time-evolution operator for the Ising model manually.
This time-evolution operator is applied to adiabatically prepare the ground state of the Ising model.
The net magnetization is then measured.

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal.

## Manifest ##

- [SimpleIsing.qs](./SimpleIsing.qs) : Q# code implementing quantum operations for this sample.
- [Program.qs](./Program.cs): Q# entry point to interact with and print out results of the Q# operations for this sample.
- [SimpleIsingSample.csproj](./SimpleIsingSample.csproj) : Main Q# project for the sample.
