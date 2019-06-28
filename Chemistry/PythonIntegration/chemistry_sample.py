import logging
## Uncomment the following lines if you want some detailed execution information:
#logging.basicConfig(level=logging.INFO)

# To start, import the qsharp.chemistry module.
# This module is part of the `qsharp` package. For detailed installation instructions, please visit:
# https://docs.microsoft.com/en-us/quantum/install-guide/python
import qsharp.chemistry
from qsharp.chemistry import load_broombridge, load_fermion_hamiltonian, load_input_state, encode, IndexConvention

# Load a fermion Hamiltonian:
fh1 = load_fermion_hamiltonian("broombridge.yaml")
print("fh1 ready.")
logging.info(fh1)

# optionally, load first the problem description from a Broombridge file, and from there
# load the fermion Hamiltonian from a problem description:
broombridge = load_broombridge("broombridge.yaml")
fh2 = broombridge.problem_description[0].load_fermion_hamiltonian()
print("fh2 ready.")
logging.info(fh2.terms)

# Here I show how to add a couple of completely made-up terms to the fh2 Hamiltonian:
terms = [ ([], 10.0), ([0,6], 1.0), ([0,2,2,0], 1.0)]
fh2.add_terms(terms)
print("terms added successfully")
logging.info(fh2)

# Similarly, you can load an input state either directly from a broombridge.yaml file,
is1 = load_input_state("broombridge.yaml", "|E1>")
print("is1 ready.")
logging.info(is1)

# or from the problem description:
is2 = broombridge.problem_description[0].load_input_state("|E1>", index_convention=IndexConvention.HalfUp)
print("is2 ready.")
logging.info(is2)


####
# An end-to-end example of how to simulate H2:
####

# Reload to make sure the quantum.qs file is correctly compiled:
qsharp.reload()

# Import the Q# operation into Python:
from Microsoft.Quantum.Samples import TrotterEstimateEnergy

# load the broombridge data for H2:
h2 = load_broombridge("h2.yaml")
problem = h2.problem_description[0]
fh = problem.load_fermion_hamiltonian()
input_state = problem.load_input_state()


# Once we have the hamiltonian and input state, we can call 'encode' to generate a Jordan-Wigner
# representation, suitable for quantum simulation:
qsharp_encoding = encode(fh, input_state)

# Simulate the Q# operation:
print('Starting simulation.')
result = TrotterEstimateEnergy.simulate(qSharpData=qsharp_encoding, nBitsPrecision=10, trotterStepSize=.4)
print(f'Trotter simulation complete. (phase, energy): {result}')
