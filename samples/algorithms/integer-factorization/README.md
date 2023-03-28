---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample uses Q# to factor integers with Shor's algorithm."
urlFragment: integer-factorization
---

# Integer Factorization Sample

This sample contains Q# code implementing Shor's quantum algorithm for
factoring integers.  It uses the [sparse simulator](https://docs.microsoft.com/azure/quantum/machines/sparse-simulator)
to simulate the algorithm for instances that require many qubits.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/azure/quantum/install-overview-qdk/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### Visual Studio Code or the Command Line

At a terminal, run the following command:

```powershell
dotnet run -- simulate
```

To provide a number to be factored, run the command:

```powershell
dotnet run -- simulate -n 15
```

### Visual Studio 2022

Open the folder containing this sample, right click on `IntegerFactorization.csproj` and select "Open in Visual Studio 2022".
Once Visual Studio has opened, ensure the `IntegerFactorization` sample is selected, and press Start in Visual Studio to run the sample.

## Manifest

- [Shor.qs](./Shor.qs): Q# implementation of Shor's algorithm.
- [Modular.qs](./Modular.qs): Q# implementation of modular arithmetic.
- [Compare.qs](./Compare.qs): Q# implementation of comparison based on AND-gates.
- [Utils.qs](./Utils.qs): Q# implementation of helper functions and operations for the AND-gate based arithmetic used in this sample.
- [Program.cs](./Program.cs): C# console application for running Shor's algorithm
- [IntegerFactorization.csproj](./IntegerFactorization.csproj): Main C# project for the sample.

## Flame Graph Visualization

This sample also contains an adapter for the [QCTraceSimulator](https://learn.microsoft.com/azure/quantum/machines/qc-trace-simulator) allowing it to produce a resource utilization stack trace which can then be used to produce a [flame graph](https://github.com/brendangregg/FlameGraph). More details can be found in [this article](https://aman3014.medium.com/flame-graphs-for-q-f4f9bb076d88).

To generate a flame graph, follow these steps:

1. Download the [flamegraph.pl script](https://raw.githubusercontent.com/brendangregg/FlameGraph/master/flamegraph.pl)
2. Install Perl
3. Run program with the `visualize` command by specifying the generator and the resource (more information in the help text) to be visualized. Save the output in a file.
4. Use flamegraph.pl with the above file to generate an svg of the flame graph.

Example usage:

```shell
dotnet run -- visualize -g 4 -r 0 > output.txt
perl flamegraph.pl output.txt > output.svg
```

<!-- markdownlint-disable no-duplicate-header -->

### Manifest

- [FlameGraphCounter.cs](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/integer-factorization/FlameGraphCounter.cs): Counter for the adapted resources estimator.
- [FlameGraphResourcesEstimator.cs](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/integer-factorization/FlameGraphResourcesEstimator.cs): The adapted resources estimator.

## quantum-viz.js Visualization

This sample also contains a custom extension to [QCTraceSimulator](https://learn.microsoft.com/azure/quantum/machines/qc-trace-simulator) that generates JSON code to be used with [quantum-viz.js](https://github.com/microsoft/quantum-viz.js).  This contains both the hierarchy of the implementation as well as the resources with respect to the position in the call stack.

To generate the JSON output for quantum-viz.js, run, for example:

```shell
dotnet run -- visualize -g 4 -r 0 --quantum-viz
```

The output would be as follows:

![Resources estimation with quantum-viz.js](https://devblogs.microsoft.com/qsharp/wp-content/uploads/sites/28/2021/12/post.gif)

<!-- markdownlint-disable no-duplicate-header -->

### Manifest

- [QuantumVizCounter.cs](QuantumVizCounter.cs): Custom listener for quantum-viz.js code generation.
- [QuantumVizEstimator.cs](QuantumVizEstimator.cs): Custom resources estimator that uses the custom listener.
