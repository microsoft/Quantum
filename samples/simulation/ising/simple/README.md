---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample demonstrates how to use manually simulate time evolution in the Ising model with Q#."
urlFragment: simple-ising
---

# Ising Simple Sample

This sample walks through constructing the time-evolution operator for the Ising model manually.
This time-evolution operator is applied to adiabatically prepare the ground state of the Ising model.
The net magnetization is then measured.

## Running the Sample

To run the sample, use the `dotnet run` command from your terminal.

## Manifest

- [SimpleIsing.qs](./SimpleIsing.qs) : Q# code implementing quantum operations for this sample.
- [Program.qs](./Program.qs): Q# entry point to interact with and print out results of the Q# operations for this sample.
- [SimpleIsingSample.csproj](./SimpleIsingSample.csproj) : Main Q# project for the sample.
