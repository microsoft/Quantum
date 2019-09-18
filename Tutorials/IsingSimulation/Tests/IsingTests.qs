namespace Microsoft.Quantum.TutorialTests {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Workshops.IsingSample;


    operation CheckSingleQubit(q : Qubit, direction : Pauli, prob : Double) : Unit {
        AssertProb([direction], [q], Zero, prob, 
            $"expecting to measure a +1 eigenstate with probability {prob} when measuring {direction}", 1e-12);
    }

    operation CheckQubits(qs : Qubit[], direction : Pauli[], prob : Double) : Unit {
        AssertProb(direction, qs, Zero, prob, 
            $"expecting to measure a +1 eigenstate with probability {prob} when measuring {direction}", 1e-12);
    }

    operation TestStatePreparation() : Unit {
        let nrQs = [2,5,10];
        let Verify = ApplyToEach(CheckSingleQubit(_, PauliX, 1.), _);

        for (i in IndexRange(nrQs)){
            using (qs = Qubit[nrQs[i]]){
                PrepareInitialState(qs);                    
                Verify(qs);
                ResetAll(qs);
            }
        }
    }

    operation TestXterm() : Unit {
        let angles = [0.1, 0.2, 0.5]; 
        let expectedZ = [1.- 0.00996671107937919, 1.- 0.0394695029985574, 1.- 0.22984884706593];

        using (q = Qubit()){
            for (i in IndexRange(angles)){
            
                ApplyXTerm(angles[i], q);
                CheckSingleQubit(q, PauliZ, expectedZ[i]);
                Reset(q);
            }
        }    
    }

    operation TestZZterm() : Unit {
        let nrQs = [4,5];
        let VerifyX = CheckSingleQubit(_, PauliX, _);
        let expectedX = [1.- 0.00996671107937919, 1.- 0.0394695029985574, 1.- 0.22984884706593];
        let VerifyXX = CheckQubits(_, [PauliX, PauliX], _);
        let expectedXX = [1.- 0.0099667110793792, 1.-0.0394695029985575, 1.-0.22984884706593]; 

        for (n in nrQs) {
            using (qs = Qubit[n]){

                let angles = [0.1, 0.2, 0.5]; 
                for (aIndex in IndexRange(angles)){
                    for (qIndex in 0 .. Length(qs) - 2){

                        ApplyToEach(H, qs);
                        ApplyZZTerm(angles[aIndex], qIndex, qs);
                        VerifyX(qs[qIndex], expectedX[aIndex]);
                        VerifyX(qs[qIndex + 1], expectedX[aIndex]);
                        ResetAll(qs);

                        ApplyToEach(H, qs);
                        ApplyZZTerm(angles[aIndex], qIndex, qs);
                        CNOT(qs[qIndex], qs[qIndex + 1]);
                        VerifyXX(qs[qIndex .. qIndex+1], expectedXX[aIndex]);
                        ResetAll(qs);
                    }                    
                }
            }
        }
    }

    operation TestTrotterStep() : Unit {
        let xCoeffs = [0.1,0.5,0.8];
        let zzCoeffs = [0.7,0.6,0.5];
        let nrQs = [3,6];
        let stepSize = 0.002;
        
        for (n in nrQs){
            using (qs = Qubit[n]){

                for (xIndex in IndexRange(xCoeffs)){
                    for (zzIndex in IndexRange(zzCoeffs)){

                        TrotterStep(stepSize, TFIM1D(zzCoeffs[zzIndex], xCoeffs[xIndex]), qs);
                        for(q in qs){
                            Rx(2.0 * stepSize * xCoeffs[xIndex], q);
                        }
                        for(idxQubit in IndexRange(qs)){
                            Adjoint ApplyZZTerm(stepSize * zzCoeffs[zzIndex], idxQubit, qs); 
                        }

                        ApplyToEach(CheckSingleQubit(_, PauliZ, 1.0), qs);
                        ResetAll(qs);                    
                    }
                }
            }
        }
    }

    operation TestAnnealing() : Unit {

        TestTrotterStep();
        let stepsSizes = [0.1, 0.3, 0.5];
        let totSteps = [10,20];
        let initialSystem = TFIM1D(0., 10.);
        let finalSystem = TFIM1D(10., 0.);

        for (stepSize in stepsSizes) {
            for (nrSteps in totSteps) {

                let steps = TimeSteps(stepSize, nrSteps);
                let System = LinearInterpolation(finalSystem, initialSystem, (steps, _));
                let Invert = Adjoint TrotterStep(stepSize, _, _);

                using (qs = Qubit[6]) {
                    
                    Anneal(initialSystem, finalSystem, steps, qs);
                    for(stepIdx in 0 .. steps::NrSteps){
                        Invert(System(stepIdx), qs);
                    }

                    ApplyToEach(CheckSingleQubit(_, PauliZ, 1.0), qs);
                    ResetAll(qs);                    
                }
            }
        } 
    }

    operation TestGroundState() : Unit {
    
        Message($"Finding ground state of a ferromagnet: ");
        for (i in 1 .. 10) {
            let measured = IsingChainGroundState(10, 1., TimeSteps (1., 100));
            Message($"    Run {i}: {measured}");
            let success = All(IsResultZero, measured) or All(IsResultOne, measured);
            Fact(success, "Failed to find the ground state of a ferromagnet.");
        }

        Message($"Finding ground state of an anti-ferromagnet: ");
        for (i in 1 .. 10) {
            let measured = IsingChainGroundState(10, -1., TimeSteps (1., 100));
            Message($"    Run {i}: {measured}");
            let (even, odd) = (measured[...2...], measured[1..2...]);
            let success = (All(IsResultZero, even) and All(IsResultOne, odd)) 
                or (All(IsResultOne, even) and All(IsResultZero, odd));
            Fact(success, "Failed to find the ground state of a ferromagnet.");
        }    
    }
}
