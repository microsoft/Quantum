# Integer Factorization Sample #

This sample contains Q# code implementing Shor's quantum algorithm for
factoring integers. The sample relies on the arithmetic library provided as
a part of Microsoft.Quantum.Canon library.

## Manifest ##

- [Shor.qs](./Shor.qs): Q# implementation of Shor's algorithm.
- [Shor.ipynb](./Shor.ipynb): Jupyter notebook host for Shor's algorithm.
- [Program.cs](./Program.cs): C# console application running Shor's algorithm
  on Quantum simulator
- [IntegerFactorization.csproj](./IntegerFactorization.csproj): Main C# project for the sample.

# Flame Graph Visualization #

This sample also contains an adapter for the [ResourcesEstimator](https://github.com/microsoft/qsharp-runtime/tree/974a385cc57c2b663e8134c1f3170f9cb8ae5fb1/src/Simulation/Simulators/ResourcesEstimator) allowing it to produce a resource utilization stack trace which can then be used to produce a flame graph. More details can be found in [this article](https://aman3014.medium.com/flame-graphs-for-q-f4f9bb076d88).

To generate a flame graph, follow these steps:

1. Clone the [flamegraph repository](https://github.com/brendangregg/FlameGraph)
2. Install perl (it is not pre-installed on Windows)
3. Run Program.cs with the visualize option by specifying the generator and the resource (more information in the help text) to be visualized. Save the output in a file.
4. Use flamegraph.pl with the above file to generate an svg of the flame graph.

Example usage:
```
dotnet run -- visualize -g 4 -r 0
cp output.txt [the flamegraph directory]
cd [the flamegraph directory]
perl flamegraph.pl output.txt > output.svg
```

## Manifest ##

- [FlameGraphCounter.cs](./FlameGraphCounter.cs): Counter for the adapted resources estimator.
- [FlameGraphResourcesEstimator](./FlameGraphResourcesEstimator.cs): The adapted resources estimator.
