import argparse
import qsharp
from pprint import pprint
from qsharp.chemistry import load_broombridge, load_fermion_hamiltonian, IndexConvention, encode
from Microsoft.Quantum.Chemistry.Samples import TrotterEstimateEnergy, OptimizedTrotterEstimateEnergy, QubitizationEstimateEnergy
qsharp.packages.add("microsoft.quantum.research")
qsharp.reload()