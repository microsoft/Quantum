import argparse
import random
import qsharp 
import Microsoft.Quantum.Samples.H2Simulation as H2Simulation

bond_lengths = H2Simulation.H2BondLengths.simulate()

for bond in range(len(bond_lengths)):
	print(f"Estimating at bond length {bond_lengths[bond]}:")
	est = min([H2Simulation.H2EstimateEnergyRPE.simulate(idxBondLength=bond, nBitsPrecision=6, trotterStepSize=1.0) for i in range(3)])
	print(f"\tEst: {est}\n")