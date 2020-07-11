# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import qsharp
import Microsoft.Quantum.Samples.H2Simulation as H2Simulation

# Call a Q# operation that takes unit `()` as its input, and returns the
# static bond lengths[float].
bond_lengths = H2Simulation.H2BondLengths.simulate()
print(f"Number of bond lengths: {len(bond_lengths)}.\n")

# Run the simulation at each bond length
for i in range(len(bond_lengths)):
    print(f"Estimating bond length {bond_lengths[i]}:")
    # The result of calling H2EstimateEnergyRPE is a float, so we take the min over
    # that to deal with the possibility that we accidentally entered into the excited
    # state instead of the ground state of interest.
    est = min([H2Simulation.H2EstimateEnergyRPE.simulate(
        idxBondLength=i, nBitsPrecision=6, trotterStepSize=1.0) for _ in range(3)])
    print(f"\tEst: {est}\n")
