// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Chemistry.VQE.StatePreparation {
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Simulation;

    operation PrepareTrialState (stateData : (Int, ((Double, Double), Int[])[]), qubits : Qubit[]) : Unit {
        let (stateType, terms) = stateData;
        if (Length(terms) == 0) {
        // Do nothing
        }
        elif (Length(terms) == 1) {
            let (complex, qubitIndices) = terms[0];
            PrepareSingleConfigurationalStateSingleSiteOccupation(qubitIndices, qubits);
        }
        else {
            PrepareSparseMultiConfigurationalState(NoOp<Qubit[]>, terms, qubits);
        }
    }
    
    /// # Summary
    /// Simple state preparation of trial state by occupying
    /// spin-orbitals
    ///
    /// # Input
    /// ## qubitIndices
    /// Indices of qubits to be occupied by electrons.
    /// ## qubits
    /// Qubits of Hamiltonian.
    operation PrepareSingleConfigurationalStateSingleSiteOccupation (qubitIndices : Int[], qubits : Qubit[]) : Unit is Adj + Ctl {
        ApplyToEachCA(X, Subarray(qubitIndices, qubits));        
    }
    
    function _PrepareSingleConfigurationalStateSingleSiteOccupation (qubitIndices : Int[]) : (Qubit[] => Unit is Adj + Ctl) {      
        return PrepareSingleConfigurationalStateSingleSiteOccupation(qubitIndices, _);
    }
    
    
    /// # Summary
    /// Sparse multi-configurational state preparation of trial state by adding excitations
    /// to initial trial state.
    ///
    /// # Input
    /// ## initialStatePreparation
    /// Unitary to prepare initial trial state.
    /// ## excitations
    /// Excitations of initial trial state represented by
    /// the amplitude of the excitation and the qubit indices
    /// the excitation acts on.
    /// ## qubits
    /// Qubits of Hamiltonian.
    operation PrepareSparseMultiConfigurationalState (initialStatePreparation : (Qubit[] => Unit), excitations : ((Double, Double), Int[])[], qubits : Qubit[]) : Unit {
        
        let nExcitations = Length(excitations);
        
        //FIXME compile error let coefficientsSqrtAbs = Mapped(Compose(Compose(Sqrt, Fst),Fst), excitations);
        mutable coefficientsSqrtAbs = new Double[nExcitations];
        mutable coefficientsNewComplexPolar = new ComplexPolar[nExcitations];
        mutable applyFlips = new Int[][nExcitations];
        
        for (idx in 0 .. nExcitations - 1) {
            let (x, excitation) = excitations[idx];
            set coefficientsSqrtAbs w/= idx <- Sqrt(AbsComplexPolar(ComplexAsComplexPolar(Complex(x))));
            set coefficientsNewComplexPolar w/= idx <- ComplexPolar(coefficientsSqrtAbs[idx], ArgComplexPolar(ComplexAsComplexPolar(Complex(x))));
            set applyFlips w/= idx <- excitation;
        }
        
        let nBitsIndices = Ceiling(Lg(IntAsDouble(nExcitations)));
        
        repeat {
            mutable success = false;
            using (auxillary = Qubit[nBitsIndices + 1]) {
                using (flag = Qubit[1]) {
                    let lookup = Mapped(_PrepareSingleConfigurationalStateSingleSiteOccupation, applyFlips);
                    let multiplexer = MultiplexerBruteForceFromGenerator(nExcitations, LookupFunction(lookup));
                    (StatePreparationComplexCoefficients(coefficientsNewComplexPolar))(LittleEndian(auxillary));
                    multiplexer(LittleEndian(auxillary), qubits);
                    (Adjoint (StatePreparationPositiveCoefficients(coefficientsSqrtAbs)))(LittleEndian(auxillary));
                    (ControlledOnInt(0, X))(auxillary, flag[0]);
                    
                    // if measurement outcome one we prepared required state
                    let outcome = Measure([PauliZ], flag);
                    set success = outcome == One;
                    ResetAll(auxillary);
                    ResetAll(flag);
                }
            }
        }
        until (success)
        fixup {
            ResetAll(qubits);
        }
    }
}
