// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.UnitTesting {

    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Circuits for exp(±i⋅ArcTan(2)⋅Z) implemented using Repeat-Until-Success (RUS) protocols
    // in term of Clifford and T gates
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Introduction 
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //
    // In general, any Repeat-Until-Success (RUS) protocol uses a circuit with measurements 
    // to implement a unitary operation on a target qubit(s). Upon success, indicated by 
    // certain measurement outcomes, a circuit used in the protocol implements desired unitary.
    // Upon failure, e.g. the other measurement outcomes, the protocol implements a unitary
    // that is easy to undo ( for example, Identity operation ). The circuit is repeated 
    // over an over again until the desired unitary is implemented. 
    // 
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// Example of a Repeat-Until-Success circuit implementing exp(i⋅ArcTan(2)⋅Z) 
    /// by Nielsen & Chuang. Gate exp(i⋅ArcTan(2)⋅Z) is also know as V gate. 
    ///
    /// # References
    /// - [ *Michael A. Nielsen , Isaac L. Chuang*,
    ///     Quantum Computation and Quantum Information ](http://doi.org/10.1017/CBO9780511976667)
    ///
    /// # See Also
    /// - For the discussion and circuit diagram see Section 1.3.6 of Nielsen & Chuang.
    /// - For the circuit diagram see Figure 1 (a) on Page 5
    ///   of the [arXiv:1311.1074v2](https://arxiv.org/pdf/1311.1074.pdf#page=5)
    operation ExpIZArcTan2NC (target : Qubit) : () {
        body {
            using(ancillas = Qubit[2]) {
                // Set both ancilla to |+⟩ state
                ApplyToEach(H, ancillas);
                repeat {
                    let (ancilla0,ancilla1) = (ancillas[0],ancillas[1]);

                    // This is just a log message, so we can see how many times we tried before 
                    // succeeding.
                    Message("Trying ...");

                    // we expect to start with both ancillas being in |+⟩ state
                    AssertProb([PauliX], [ancilla0], Zero, 1.0, "", 1e-10 );
                    AssertProb([PauliX], [ancilla1], Zero, 1.0, "", 1e-10 );

                    // use CCNOT with 4 T gates 
                    CCNOT3(ancilla0,ancilla1, target);
                    S(target);
                    // use CCNOT with 4 T gates 
                    CCNOT3(ancilla0,ancilla1, target);
                    Z(target);

                    // Before the measurements probability of measuring |+⟩ state on both 
                    // ancillas is 3/4
                    AssertProb(
                        [PauliX], [ancilla0], Zero, 0.75, 
                        "Error: the probability to measure |+⟩ in the first ancilla must be 3/4", 
                        1e-10);

                    AssertProb(
                        [PauliX], [ancilla1], Zero, 0.75,
                        "Error: the probability to measure |+⟩ in the second ancilla must be 3/4", 
                        1e-10);
                    
                    let outcome0 = Measure([PauliX], [ancilla0]);

                    // After the first ancilla has been measured the probability is conditional 
                    // upon measurement outcome. 
                    // If we measured Zero on the first ancilla, the probability of 
                    // measuring |+⟩ on the second ancilla is 5/6
                    mutable prob = ToDouble(5) / ToDouble(6);

                    // If we measured One on the first ancilla, the probability of 
                    // measuring |+⟩ on the second ancilla is 1/2
                    if( outcome0 == One ) { set prob = 0.5; }

                    AssertProb(
                        [PauliX], [ancilla1], Zero, prob, 
                        $"Error:the probability to measure |+⟩ in the first ancilla must be {prob}",
                        1e-10);
                    
                    let outcome1 = Measure([PauliX], [ancilla1]);
                }
                until( (outcome0 == Zero) && (outcome1 == Zero) )
                fixup {
                    // Upon failure the identity gate has been applied to the target qubit
                    // Now let us record the failure to log.
                    let msg1 = $"We failed. Outcomes of measuring first and second ancilla ";
                    let msg2 = $"were {(outcome0,outcome1)}. Applying fix-up and trying again";
                    Message(msg1 + msg2);
                    
                    // Make sure that both ancilla are back to |+⟩ state
                    if( outcome0 == One ) { Z(ancilla0); }
                    if( outcome1 == One ) { Z(ancilla1); }
                }

                // If both outcomes are Zero we successfully applied exp(i⋅ArcTan(2)⋅Z)
                Message("Success!");
                // Return ancillas back to |0⟩ state
                ApplyToEach(H, ancillas);
            }
        }
        adjoint
        {
            // We can use the following equation to implement the Adjoint:
            // X exp(i⋅ArcTan(2)⋅Z) X = exp(i⋅ArcTan(2)⋅XZX) = exp(- i⋅ArcTan(2)⋅Z)
            X(target);
            ExpIZArcTan2NC(target);
            X(target);
        }
    }

    /// # Summary
    /// Example of a Repeat-Until-Success circuit implementing exp(i⋅ArcTan(2)⋅Z) 
    /// by Paetznick & Svore. Gate exp(i⋅ArcTan(2)⋅Z) is also know as V gate.
    /// # References
    /// - [ *Adam Paetznick, Krysta M. Svore*,
    ///     Quantum Information & Computation 14(15 & 16): 1277-1301 (2014)
    ///   ](https://arxiv.org/abs/1311.1074)
    /// # See Also
    /// - For the circuit diagram see Figure 1 (c) on Page 
    ///   of the [arXiv:1311.1074v2](https://arxiv.org/pdf/1311.1074.pdf#page=5)
    operation ExpIZArcTan2PS( target : Qubit) : () {
        body {
            using(ancillas = Qubit[1]) { 
                let ancilla = ancillas[0];
                H(ancilla); // Set ancilla to |+⟩ state 

                // Note that because T and Z on the target commutes through the control, 
                // we can just count the number of T's we need to apply over the course of 
                // the protocol and apply one or zero of T's in the end. 
                mutable TGatesToApplyInTheEnd = 0; 

                repeat {
                    // This is just a log message, so we can see how many times we tried before 
                    // succeeding.
                    Message("Trying ...");

                    // we expect to start with ancilla being in |+⟩ state
                    AssertProb(
                        [PauliX], [ancilla], Zero, 1.0,
                        "Ancilla must be in |+⟩ state", 1e-10 );
                    RepeatUntilSuccessStatePreparation(ancilla);

                    CNOT(target,ancilla);
                    T(ancilla);

                    // This is instead of Z(target), T(target)
                    set TGatesToApplyInTheEnd = TGatesToApplyInTheEnd + 5;

                    // The probability to measure |+⟩ on ancilla is 5/6
                    AssertProb(
                        [PauliX], [ancilla], Zero, ToDouble(5) / ToDouble(6), 
                        $"The probability to measure |+⟩ on ancilla must be 5/6",
                        1e-10);

                    let outcome = Measure([PauliX], [ancilla]);
                }
                until( outcome == Zero ) 
                fixup {
                    // Upon failure the identity gate has been applied to the target qubit
                    // Now let us record the failure to log.
                    Message("We failed. Applying fix-up");
                    
                    // This is instead of Z(target)
                    set TGatesToApplyInTheEnd = TGatesToApplyInTheEnd + 4;
                    
                    // Make sure that ancilla is back to |+⟩ state
                    Z(ancilla);
                }

                // If outcome is Zero we successfully applied exp(i⋅ArcTan(2)⋅Z)
                Message("Success!");

                // Now apply the required T,S and Z gates. 
                // If TGatesToApplyInTheEnd is odd one more T gates is applied, and if 
                // TGatesToApplyInTheEnd is even there are no T gates to apply 
                // In other words apply exp( i⋅π⋅k/2² |1⟩⟨1| ), where k = TGatesToApplyInTheEnd
                R1Frac(TGatesToApplyInTheEnd,2, target);

                // Now return ancilla to |0⟩ state
                H(ancilla);
            }
        }
        adjoint {
            // We can use the following equation to implement the Adjoint:
            // X exp(i⋅ArcTan(2)⋅Z) X = exp(i⋅ArcTan(2)⋅XZX) = exp(- i⋅ArcTan(2)⋅Z)
            X(target);
            ExpIZArcTan2PS(target);
            X(target);
        }
    }

    /// # Summary
    /// Prepares state (√2/√3,1/√3) starting from a |+⟩ state
    /// using Repeat-Until-Success protocol. 
    /// # Sea also 
    /// - Used in @"Microsoft.Quantum.Samples.UnitTesting.ExpIZArcTan2PS"
    operation RepeatUntilSuccessStatePreparation( target : Qubit ) : () {
        body {
            using( qubits = Qubit[1] ) {
                let ancilla = qubits[0];
                H(ancilla);
                repeat {
                    // we expect target and ancilla qubit to be in |+⟩ state
                    AssertProb(
                        [PauliX], [target], Zero, 1.0,
                        "target qubit should be in |+⟩ state", 1e-10 );
                    AssertProb(
                        [PauliX], [ancilla], Zero, 1.0,
                        "ancilla qubit should be in |+⟩ state", 1e-10 );
                    
                    (Adjoint T)(ancilla);
                    CNOT(target,ancilla);
                    T(ancilla);

                    // Probability of measuring |+⟩ state on ancilla is 3/4
                    AssertProb( 
                        [PauliX], [ancilla], Zero, ToDouble(3) / ToDouble(4), 
                        "Error: the probability to measure |+⟩ in the first ancilla must be 3/4",
                        1e-10);

                    // if measurement outcome zero we prepared required state 
                    let outcome = Measure([PauliX], [ancilla]);
                }
                until( outcome == Zero )
                fixup {
                    // Bring ancilla and target back to |+⟩ state
                    if( outcome == One ) {
                        Z(ancilla);
                        X(target);
                        H(target);
                    }
                }
                // Return ancilla back to Zero state
                H(ancilla);
            }
        }
    }
}
