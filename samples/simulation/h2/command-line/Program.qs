// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.H2Simulation {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;

    @EntryPoint()
    operation RunH2Simulation() : Unit {
        // We call the function H2BondLengths to get the bond lengths at which we want to estimate
        // the energy.
        for (index, length) in Enumerated(H2BondLengths()) {
            // Run the simulation at each bond length and print the answers out to the console.
            Message($"Estimating at bond length {length}:");
            let estimate = EstimateAtBondLength(index);
            Message($"\tEst: {estimate}\n");
        }
    }

    internal operation EstimateAtBondLength(index : Int) : Double {
        // In Operations.qs, we defined the operation that performs the actual estimation; we can
        // call it here. Since the operation has type
        //
        //     (idxBondLength : Int, nBitsPrecision : Int, trotterStepSize : Double) => Double
        //
        // we pass the index along with that we want six bits of precision and step size of 1.
        //
        // The result of calling H2EstimateEnergyRPE is a Double, so we can minimize over that to
        // deal with the possibility that we accidentally entered into the excited state instead of
        // the ground state of interest.
        let estimates = DrawMany(Delay(H2EstimateEnergyRPE, (index, 6, 1.0), _), 3, ());
        let infinity = 1.0 / 0.0;
        return Fold(MinD, infinity, estimates);
    }
}
