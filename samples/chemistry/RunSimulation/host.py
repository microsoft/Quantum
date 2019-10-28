import argparse
import qsharp
from pprint import pprint
from qsharp.chemistry import load_broombridge, load_fermion_hamiltonian, IndexConvention, encode
from Microsoft.Quantum.Chemistry.Samples import TrotterEstimateEnergy, OptimizedTrotterEstimateEnergy, QubitizationEstimateEnergy
qsharp.packages.add("microsoft.quantum.research")
qsharp.reload()

path = '../IntegralData/YAML/lih_sto-3g_0.800_int.yaml'

description = load_broombridge(path).problem_description[0]

hamiltonian = description.load_fermion_hamiltonian(IndexConvention.UpDown)

# If `wavefunction_label` is not specified, it loads the greedy (Hartree-Fock) state.
wave_function = description.load_input_state()

jordan_wigner = encode(hamiltonian, wave_function)

repitions = 1
n_bits = 10
step_size = 0.4

#Run Jordan-Wigner

for i in range(repitions):
	resp = TrotterEstimateEnergy.simulate(qSharpData=jordan_wigner, nBitsPrecision=n_bits, trotterStepSize=step_size)
	#"Trotter simulation. phase: {phaseEst}; energy {energyEst}"
	print(resp)

#Run OptimizedTrotterEstimateEnergy

for i in range(repitions):
	resp = OptimizedTrotterEstimateEnergy.simulate(qSharpData=jordan_wigner, nBitsPrecision=n_bits-1, trotterStepSize=step_size)
	#"Trotter simulation. phase: {phaseEst}; energy {energyEst}"
	print(resp)

# Run QubitizedJordanWigner

for i in range(repitions):
	resp = QubitizationEstimateEnergy.simulate(qSharpData=jordan_wigner, nBitsPrecision=n_bits-2)
	#"Trotter simulation. phase: {phaseEst}; energy {energyEst}"
	print(resp)