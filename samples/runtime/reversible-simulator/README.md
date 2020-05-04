# A simple reversible simulator

This samples shows how to use the `IQuantumProcessor` interface to build a
simple reversible simulator.  A reversible simulator can simulate quantum
programs that consist only of *classical* operations: `X`, `CNOT`, `CCNOT`
(Toffoli gate), or arbitrarily controlled `X` operations.  Since a reversible
simulator can represent the quantum state by assigning one Boolean value to each
qubit, it can run even quantum programs that consist of thousands of qubits.
This simulator is very useful for testing quantum operations that evaluate
Boolean functions.

## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample ##

To run the sample, use the `dotnet run` command from your terminal.

## Manifest ##

- [Operation.qs](Operation.qs): Q# code implementing quantum operations for this sample.
- [Simulator.cs](Simulator.cs): C# implementation of a reversible simulator using the `IQuantumProcessor` interface.
- [Driver.cs](Driver.cs): C# code running the quantum operations with the reversible simulator.
- [reversible-simulator.csproj](reversible-simulator.csproj): C# project for the sample.
