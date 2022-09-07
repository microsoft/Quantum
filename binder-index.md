---
jupyter:
  jupytext:
    cell_markers: region,endregion
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.2'
      jupytext_version: 1.5.2
  kernelspec:
    display_name: Q#
    language: qsharp
    name: iqsharp
---

<!-- markdownlint-disable-file no-inline-html -->
<!-- cspell:words qrng chsh qpic qaoa -->

# Quantum Development Kit Samples

These samples demonstrate the use of Q# and the Quantum Development Kit for a variety of different quantum computing tasks.

Many samples can be used directly in your browser using either Q# on its own, or Q# together with Python.
Alternatively, you can [create a new command line terminal](http://127.0.0.1:8888/terminals/new) to run most Q# standalone samples, as well as samples that demonstrate how to use Q# together with Python or .NET.

A small number of the samples have additional installation requirements beyond those for the rest of the Quantum Development Kit.
These are noted in the README.md files for each sample, along with complete installation instructions.

<table id="samples-list">
  <thead>
    <tr>
      <th colspan="2">Sample</th>
      <th colspan="2">Run in browser...</th>
      <th colspan="2">Run at command line...</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Getting started:</strong></td>
      <td><strong><a href="./samples/getting-started/intro-to-iqsharp/README.md">Intro to IQ#</a></strong></td>
      <td><a href="./samples/getting-started/intro-to-iqsharp/Notebook.ipynb">Q# notebook</a></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/getting-started/measurement/README.md">Measurement</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/getting-started/qrng/README.md">Quantum random number generator</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/getting-started/simple-algorithms/README.md">Simple quantum algorithms</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/getting-started/teleportation/README.md">Teleportation</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/getting-started/azure-quantum/cirq/README.md">Cirq</a></strong></td>
      <td></td>
      <td><a href="./samples/getting-started/azure-quantum/cirq">Cirq + Python</a></td>
      <td>N/A</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/getting-started/azure-quantum/qiskit/README.md">Qiskit</a></strong></td>
      <td></td>
      <td><a href="./samples/getting-started/azure-quantum/qiskit">Qiskit + Python</a></td>
      <td>N/A</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/getting-started/azure-quantum/provider-specific/README.md">Provider-specific format</a></strong></td>
      <td></td>
      <td><a href="./samples/getting-started/azure-quantum/provider-specific">Provider-specific format + Python</a></td>
      <td>N/A</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/getting-started/simulation/README.md">Simulation</a></strong></td>
      <td><a href="./samples/getting-started/simulation/LargeSimulation.ipynb">Q# notebook</a></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Algorithms:</strong></td>
      <td><a href="./samples/algorithms/chsh-game/README.md"><strong>CHSH Game</strong></a></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="./samples/algorithms/database-search/README.md"><strong>Database Search</strong></a></td>
      <td><a href="./samples/algorithms/database-search/Database%20Search.ipynb">Q# notebook</a></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="./samples/algorithms/noisy-dj/README.md"><strong>Deutsch–Jozsa w/ noise</strong></a></td>
      <td><a href="./samples/algorithms/noisy-dj/Deutsch–Jozsa%20with%20Noise.ipynb">Python notebook</a></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><a href="./samples/algorithms/integer-factorization/README.md"><strong>Integer factorization</strong></a></td>
      <td></td>
      <td><a href="./samples/algorithms/integer-factorization/host.py">Q# + Python</a></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="./samples/algorithms/oracle-synthesis/README.md"><strong>Oracle synthesis</strong></a></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="./samples/algorithms/order-finding/README.md"><strong>Order finding</strong></a></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="./samples/algorithms/repeat-until-success/README.md"><strong>Repeat-Until-Success (RUS)</strong></a></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="./samples/algorithms/reversible-logic-synthesis/README.md"><strong>Reversible Logic Synthesis</strong></a></td>
      <td></td>
      <td><a href="./samples/algorithms/reversible-logic-synthesis/host.py">Q# + Python</a></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="./samples/algorithms/simple-grover/README.md"><strong>Simple Grover's Algorithm</strong></a></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="./samples/algorithms/variational-algorithms/README.md"><strong>Variational quantum algorithms</strong></a></td>
      <td></td>
      <td><a href="./samples/algorithms/variational-algorithms/Variational%20Quantum%20Algorithms.ipynb">Q# + Python</a></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="./samples/algorithms/sudoku-grover/README.md"><strong>Sudoku solving with Grover's</strong></a></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td><strong>Arithmetic:</strong></td>
      <td><strong><a href="./samples/arithmetic/quantum-adders/README.md">Adder</a></strong></td>
      <td><a href="./samples/arithmetic/quantum-adders/AdderExample.ipynb">Q# notebook</a></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Azure Quantum service:</strong></td>
      <td><strong><a href="./samples/azure-quantum/chemistry/README.md">Chemistry</a></strong></td>
      <td></td>
      <td>Q# + Python</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/azure-quantum/grover/README.md">Grover's search</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/azure-quantum/hidden-shift/README.md">Hidden shift</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/azure-quantum/parallel-qrng/README.md">Parallel QRNG</a></strong></td>
      <td><a href="./samples/azure-quantum/parallel-qrng/ParallelQrng.ipynb">Q# notebook</a></td>
      <td><a href="./samples/azure-quantum/parallel-qrng/parallel_qrng.py">Q# + Python</a></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/azure-quantum/ising-model/README.md">Ising model simulation</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/azure-quantum/teleport/README.md">Teleportation</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/azure-quantum/qae-numerical-integration/README.md">Numerical Integration with QAE</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# + python</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Characterization:</strong></td>
      <td><strong><a href="./samples/characterization/phase-estimation/README.md">Bayesian Phase Estimation</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/characterization/process-tomography/README.md">Process tomography</a></strong></td>
      <td></td>
      <td><a href="./samples/characterization/process-tomography/tomography-sample.ipynb">Q# + Python</a></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/characterization/randomized-benchmarking/README.md">Randomized benchmarking</a></strong></td>
      <td></td>
      <td><a href="./samples/characterization/randomized-benchmarking/randomized-benchmarking.ipynb">Q# + Python</a></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Chemistry:</strong></td>
      <td><strong><a href="./samples/chemistry/AnalyzeHamiltonian">Hamiltonian analysis</a></strong></td>
      <td></td>
      <td><a href="./samples/chemistry/AnalyzeHamiltonian/host.py">Q# + Python</a></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/chemistry/CreateHubbardHamiltonian">Hubbard model</a></strong> (data model)</td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/chemistry/SimulateHubbardHamiltonian">Hubbard model</a></strong> (simulation)</td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/chemistry/GetGateCount">Gate counting</a></strong></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET / PowerShell</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/chemistry/LithiumHydrideGUI">LiH</a></strong> (GUI)</td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET / Electron</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/chemistry/MolecularHydrogen">Molecular hydrogen</a></strong> (command-line)</td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/chemistry/MolecularHydrogenGUI">Molecular hydrogen</a></strong> (GUI)</td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET / Electron</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/chemistry/RunSimulation">Simulation</a></strong> (GUI)</td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/chemistry/PythonIntegration/README.md">Python interoperability</a></strong></td>
      <td></td>
      <td><a href="./samples/chemistry/PythonIntegration/chemistry_sample.py">Q# + Python</a></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Characterization:</strong></td>
      <td><strong><a href="./samples/characterization/phase-estimation/README.md">Bayesian Phase Estimation</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Diagnostics:</strong></td>
      <td><strong><a href="./samples/diagnostics/dumping/README.md">Dumping states and operations</a></strong></td>
      <td><a href="./samples/diagnostics/dumping/Dumping%20States%20and%20Operations.ipynb">Q# notebook</a></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/diagnostics/facts-and-assertions/README.md">Facts and assertions</a></strong></td>
      <td><a href="./samples/diagnostics/facts-and-assertions/Facts%20and%20Assertions.ipynb">Q# notebook</a></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/diagnostics/unit-testing/README.md">Unit testing</a></strong></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/diagnostics/visualization/README.md">Visualizing quantum programs</a></strong></td>
      <td><a href="./samples/diagnostics/visualization/Visualizing%20Quantum%20Programs.ipynb">Q# notebook</a></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Error correction:</strong></td>
      <td><strong><a href="./samples/error-correction/bit-flip-code/README.md">Bit flip code</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/error-correction/syndrome/README.md">Syndrome measurement</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Interoperability:</strong></td>
      <td><strong><a href="./samples/interoperability/python/README.md">Python</a></strong></td>
      <td></td>
      <td><a href="./samples/interoperability/python/python-qsharp-interop.ipynb">Q# + Python</a></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/interoperability/dotnet/README.md">.NET</a></strong></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td><strong>Machine learning:</strong></td>
      <td><strong><a href="./samples/machine-learning/half-moons/README.md">Half moons</a></strong> (serial)</td>
      <td></td>
      <td><a href="./samples/machine-learning/half-moons/HalfMoons.ipynb">Q# + Python</a></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/machine-learning/parallel-half-moons/README.md">Half moons</a></strong> (parallel)</td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/machine-learning/wine/README.md">Half moons</a></strong> (parallel)</td>
      <td></td>
      <td><a href="./samples/machine-learning/wine/host.py">Q# + Python</a></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td><strong>Numerics:</strong></td>
      <td><strong><a href="./samples/numerics/custom-mod-add/README.md">Custom modular addition</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/numerics/evaluating-functions/README.md">Evaluating functions</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/numerics/resource-counting/README.md">Resource counting</a></strong></td>
      <td><a href="./samples/numerics/resource-counting/ResourceEstimation.ipynb">Q# notebook</a></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Runtime:</strong></td>
      <td><strong><a href="./samples/runtime/autosubstitution/README.md">Auto-substitution</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/runtime/oracle-emulation/README.md">Oracle emulation</a></strong></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/runtime/qpic-simulator/README.md">⟨q|pic⟩ simulator</a></strong></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/runtime/reversible-simulator-simple/README.md">Reversible simulator</a></strong> (simple)</td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/runtime/reversible-simulator-advanced/README.md">Reversible simulator</a></strong> (advanced)</td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/runtime/simulator-with-overrides/README.md">Simulator w/ overrides</a></strong></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/runtime/state-visualizer/README.md">State visualizer</a></strong></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td><strong>Quantum simulation:</strong></td>
      <td><strong><a href="./samples/simulation/h2/command-line/README.md">H₂</a></strong> (command-line)</td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/simulation/h2/gui/README.md">H₂</a></strong> (GUI)</td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET / Electron</td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/simulation/hubbard/README.md">Hubbard model</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/simulation/ising/README.md">Ising model</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/simulation/gaussian-initial-state/README.md">Gaussian state preparation</a></strong></td>
      <td></td>
      <td><a href="./samples/simulation/gaussian-initial-state/host.py">Q# + Python</a></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="./samples/simulation/qaoa/README.md">Quantum approximate optimization algorithm</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
  </tbody>
</table>
