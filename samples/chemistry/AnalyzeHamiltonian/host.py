# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import numpy as np
from numpy import linalg as LA
from qsharp.chemistry import load_broombridge, load_fermion_hamiltonian, IndexConvention


LiH = '../IntegralData/YAML/lih_sto-3g_0.800_int.yaml'

print(f"Processing the following file: {LiH}")
broombridge = load_broombridge(LiH)
general_hamiltonian = broombridge.problem_description[0].load_fermion_hamiltonian(
    index_convention=IndexConvention.UpDown)
print("End of file. Computing One-norms:")
for term, matrix in general_hamiltonian.terms:
    one_norm = LA.norm(np.asarray([v for k, v in matrix], dtype=np.float32), ord=1)
    print(f"One-norm for term type {term}: {one_norm}")
