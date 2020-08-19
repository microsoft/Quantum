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

# Quantum Development Kit Samples


These samples demonstrate the use of Q# and the Quantum Development Kit for a variety of different quantum computing tasks.

Many samples can be used directly in your browser using either Q# on its own, or Q# togther with Python.
Alternatively, you can [create a new command line terminal](http://127.0.0.1:8888/terminals/new) to run Q# standalone samples, as well as samples that demonstrate how to use Q# together with Python or .NET.

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
      <td><strong><a href="/notebooks/samples/getting-started/intro-to-iqsharp/README.md">Intro to IQ#</a></strong></td>
      <td><a href="/notebooks/samples/getting-started/intro-to-iqsharp/Notebook.ipynb">Q# notebook</a></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="/notebooks/samples/getting-started/measurement/README.md">Measurement</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="/notebooks/samples/getting-started/qrng/README.md">Quantum random number generator</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="/notebooks/samples/getting-started/simple-algorithms/README.md">Simple quantum algorithms</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><strong><a href="/notebooks/samples/getting-started/teleportation/README.md">Teleportation</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Algorithms:</strong></td>
      <td><a href="/notebooks/samples/algorithms/chsh-game/README.md"><strong>CHSH Game</strong></a></td>
      <td></td>
      <td><a href="/notebooks/samples/algorithms/chsh-game/host.py">Q# + Python</a></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><a href="/notebooks/samples/algorithms/database-search/README.md"><strong>Database Search</strong></a></td>
      <td><a href="/notebooks/samples/algorithms/database-search/Database%20Search.ipynb">Q# notebook</a></td>
      <td><a href="/notebooks/samples/algorithms/database-search/host.py">Q# + Python</a></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><a href="/notebooks/samples/algorithms/integer-factorization/README.md"><strong>Integer factorization</strong></a></td>
      <td></td>
      <td><a href="/notebooks/samples/algorithms/integer-factorization/host.py">Q# + Python</a></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td></td>
      <td><a href="/notebooks/samples/algorithms/oracle-synthesis/README.md"><strong>Oracle synthesis</strong></a></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="/notebooks/samples/algorithms/order-finding/README.md"><strong>Order finding</strong></a></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="/notebooks/samples/algorithms/repeat-until-success/README.md"><strong>Repeat-Until-Success (RUS)</strong></a></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="/notebooks/samples/algorithms/reversible-logic-synthesis/README.md"><strong>Reversible Logic Synthesis</strong></a></td>
      <td></td>
      <td><a href="/notebooks/samples/algorithms/reversible-logic-synthesis/host.py">Q# + Python</a></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="/notebooks/samples/algorithms/simple-grover/README.md"><strong>Simple Grover's Algorithm</strong></a></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Arithmetic:</strong></td>
      <td><strong><a href="/notebooks/samples/arithmetic/README.md">Adder</a></strong></td>
      <td><a href="/notebooks/samples/arithmetic/AdderExample.ipynb">Q# notebook</a></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Characterization:</strong></td>
      <td><strong><a href="/notebooks/samples/characterization/phase-estimation/README.md">Bayesian Phase Estimation</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Chemistry:</strong></td>
      <td>TODO</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>    
    <tr>
      <td><strong>Characterization:</strong></td>
      <td><strong><a href="/notebooks/samples/characterization/phase-estimation/README.md">Bayesian Phase Estimation</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Diagnostics:</strong></td>
      <td><strong><a href="/notebooks/samples/diagnostics/unit-testing/README.md">Unit testing</a></strong></td>
      <td></td>
      <td></td>
      <td></td>
      <td>Q# + .NET</td>
    </tr>
    <tr>
      <td><strong>Error correction:</strong></td>
      <td><strong><a href="/notebooks/samples/error-correction/bit-flip-code/README.md">Bit flip code</a></strong></td>
      <td></td>
      <td></td>
      <td>Q# standalone</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Interoperability:</strong></td>
      <td>TODO</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Machine learning:</strong></td>
      <td>TODO</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Numerics:</strong></td>
      <td>TODO</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Runtime:</strong></td>
      <td>TODO</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Simulation:</strong></td>
      <td>TODO</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>
