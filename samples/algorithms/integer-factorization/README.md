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
factoring integers. The sample relies on the arithmetic library provided as
a part of Microsoft.Quantum.Canon library.

## Manifest

- [Shor.qs](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/integer-factorization/Shor.qs): Q# implementation of Shor's algorithm.
- [Program.cs](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/integer-factorization/Program.cs): C# console application running Shor's algorithm
  on Quantum simulator
- [IntegerFactorization.csproj](https://github.com/microsoft/Quantum/blob/main/samples/algorithms/integer-factorization/IntegerFactorization.csproj): Main C# project for the sample.

## Flame Graph Visualization

This sample also contains an adapter for the [ResourcesEstimator](https://docs.microsoft.com/azure/quantum/user-guide/machines/resources-estimator) allowing it to produce a resource utilization stack trace which can then be used to produce a [flame graph](https://github.com/brendangregg/FlameGraph). More details can be found in [this article](https://aman3014.medium.com/flame-graphs-for-q-f4f9bb076d88).

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

This sample also contains a custom [ResourcesEstimator](https://docs.microsoft.com/azure/quantum/user-guide/machines/resources-estimator) that generates JSON code to be used with [quantum-viz.js](https://github.com/microsoft/quantum-viz.js).  This contains both the hierarchy of the implementation as well as the resources with respect to the position in the call stack.

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
