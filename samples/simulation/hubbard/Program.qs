// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.Hubbard {

    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RunProgram () : Unit {
        
        // For this example, we'll consider a loop of six sites, each one of which
        // is simulated using two qubits.
        let nSites = 6;

        // Let us choose a repulsion term somewhat larger than the hopping term 
        // to favor single-site occupancy. 
        let (uCoefficient, tCoefficient) = (1.0, 0.2);

        // We need to choose the number of bits of precision in phase estimation. Bear in mind
        // that this is bits of precision before rescaling by the trotterStepSize. A smaller
        // trotterStepSize would require more bits of precision to obtain the same absolute 
        // accuracy.
        let bitsPrecision = 7;

        // We choose a small trotter step size for improved simulation error.
        // This should be at least small enough to avoid aliasing of estimated phases.
        let trotterStepSize = 0.5;
            
        // For diagnostic purposes, before we proceed to the next step, we'll print
        // out a description of the parameters we just defined.
        Message("Hubbard model ground state energy estimation:");
        Message($"    {nSites} sites");
        Message($"    {uCoefficient} repulsion term coefficient");
        Message($"    {tCoefficient} hopping term coefficient");
        Message($"    {bitsPrecision} bits of precision");
        Message($"    {(2.0 ^  (-IntAsDouble(bitsPrecision))) / trotterStepSize} energy estimate error from phase estimation alone");
        Message($"    {trotterStepSize} time step");


        // Now that we've defined everything we need, let's proceed to
        // actually call the operation. Since there's a finite chance of successfully
        // projecting onto the ground state, we will call it several times, 
        // reporting the estimated energy after each attempt.

        for (idxAttempt in 1 .. 10)
        {
            let energyEst = EstimateHubbardAntiFerromagneticEnergy(nSites, tCoefficient, uCoefficient, bitsPrecision, trotterStepSize);
            Message($"Energy estimated in attempt {idxAttempt}: {energyEst}");
        }

    }
}
