---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample uses Q# to find the order of a cycle in a permutation."
urlFragment: order-finding
---

# Order Finding

This sample uses a quantum algorithm to find the order of a cycle in a permutation.
It succeeds with a higher probability than the classical best possible strategy.
A challenge in the algorithm is to find a quantum circuit to realize the input permutation.
We utilize [reversible logic synthesis](../reversible-logic-synthesis) for this task.

The algorithm has been presented by L.M.K. Vandersypen, M. Steffen, G. Breyta, C.S. Yannoni, R. Cleve,
and I.L. Chuang in [Experimental realization of an order-finding algorithm with an NMR quantum computer](https://doi.org/10.1103/PhysRevLett.85.5452),
*Phys. Rev. Lett.* **85**, 5452, 2000.
The quantum algorithm in the Q# file is implemented for permutations over 2ⁿ elements, however, the classical post-processing
in the C# file is restricted to permutations over 4 elements.

## Running the Sample

To run the sample, use the `dotnet run --index VALUE` command from your terminal.
The value `VALUE` passed to the index argument must be between 0 and 3 inclusive.

## Manifest

- **OrderFinding/**
  - [OrderFinding.csproj](./OrderFinding.csproj): Main C# project for the example.
  - [Program.qs](./Program.qs): Q# operations and functions making up the quantum application for order finding.
  - [OrderFinding.qs](./OrderFinding.qs): The Q# implementation of the order finding algorithm.

## Example run

```text
Permutation: [1 2 3 0]
Find cycle length at index 0

Exact order: 4

Guess classically:
2: 50.78%
4: 49.22%

Guess with Q#:
4: 55.27%
2: 25.29%
1: 15.72%
3: 3.71%
```
