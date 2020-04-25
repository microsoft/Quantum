# Oracle Synthesis #

This sample shows the implementation of an arbitrary quantum oracle function
using Hadamard gates, CNOT gates, and arbitrary Z-rotations.  The algorithm is
based on papers by N. Schuch and J. Siewert [[Programmable networks for quantum
algorithms](https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.91.027902),
*Phys. Rev. Lett.* **91**, 027902, 2003] and J. Welch, D. Greenbaum, S. Mostame,
and A. Aspuru-Guzik [[Efficient quantum circuits for diagonal unitaries without
ancillas](http://iopscience.iop.org/article/10.1088/1367-2630/16/3/033040/meta),
*New J. of Phys.* **16**, 033040, 2014].
 
## Manifest ##
 
- **OracleSynthesis/**
  - [OracleSynthesis.csproj](./OracleSynthesis.csproj): Main C# project for the example.
  - [Program.cs](./Program.cs): C# code to call the operations defined in Q#.
  - [OracleSynthesis.qs](./OracleSynthesis.qs): The Q# implementation for oracle synthesis.
