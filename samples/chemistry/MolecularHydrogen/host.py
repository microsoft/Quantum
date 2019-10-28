import argparse
import numpy as np
from numpy import linalg as LA
from qsharp.chemistry import load_broombridge, load_fermion_hamiltonian, IndexConvention, encode

n_orbitals = 2
n_electrons = 2
energy_offset = 0.713776188