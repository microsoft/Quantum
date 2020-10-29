// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;


    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Circuits for exp(±i⋅ArcTan(2)⋅Z) implemented using Repeat-Until-Success (RUS) protocols
    // in term of Clifford and T gates
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Introduction
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // In general, any Repeat-Until-Success (RUS) protocol uses a circuit with measurements
    // to implement a unitary operation on a target qubit(s). Upon success, indicated by
    // certain measurement outcomes, a circuit used in the protocol implements desired unitary.
    // Upon failure, e.g. the other measurement outcomes, the protocol implements a unitary
    // that is easy to undo ( for example, Identity operation ). The circuit is repeated
    // over an over again until the desired unitary is implemented.

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
    operation ExpIZArcTan2NC (target : Qubit) : Unit {

        body (...) {
            using ((aux0, aux1) = (Qubit(), Qubit())) {

                // Set both ancilla to |+⟩ state
                ApplyToEach(H, [aux0, aux1]);

                repeat {
                    // This is just a log message, so we can see how many times we tried before
                    // succeeding.
                    Message("Trying ...");

                    // We expect to start with both auxillary qubits to start
                    // in the |+⟩ state.
                    AssertMeasurement([PauliX], [aux0], Zero, "");
                    AssertMeasurement([PauliX], [aux1], Zero, "");

                    // use CCNOT with 4 T gates
                    CCNOT3(aux0, aux1, target);
                    S(target);

                    // use CCNOT with 4 T gates
                    CCNOT3(aux0, aux1, target);
                    Z(target);

                    // Before the measurements probability of measuring |+⟩ state on both
                    // ancillas is 3/4
                    AssertMeasurementProbability([PauliX], [aux0], Zero, 0.75, "Error: the probability to measure |+⟩ in the first ancilla must be 3/4", 1E-10);
                    AssertMeasurementProbability([PauliX], [aux1], Zero, 0.75, "Error: the probability to measure |+⟩ in the second ancilla must be 3/4", 1E-10);
                    let outcome0 = Measure([PauliX], [aux0]);

                    // After the first auxiliary qubit has been measured the probability is conditional
                    // upon measurement outcome.
                    // If we measured Zero on the first auxiliary qubit, the probability of
                    // measuring |+⟩ on the second auxiliary qubit is 5/6
                    // If we measured One on the first auxiliary qubit, the probability of
                    // measuring |+⟩ on the second ancilla is 1/2
                    let prob = outcome0 == One ? 0.5 | 5.0 / 6.0;

                    AssertMeasurementProbability([PauliX], [aux1], Zero, prob, $"Error:the probability to measure |+⟩ in the first ancilla must be {prob}", 1E-10);
                    let outcome1 = Measure([PauliX], [aux1]);
                }
                until (outcome0 == Zero and outcome1 == Zero)
                fixup {

                    // Upon failure the identity gate has been applied to the target qubit
                    // Now let us record the failure to log.
                    Message(
                        "We failed. Outcomes of measuring first and second auxiliary qubits " +
                        $"were {(outcome0, outcome1)}. Applying fix-up and trying again."
                    );

                    // Make sure that both ancilla are back to |+⟩ state
                    if (outcome0 == One) {
                        Z(aux0);
                    }

                    if (outcome1 == One) {
                        Z(aux1);
                    }
                }

                // If both outcomes are Zero we successfully applied exp(i⋅ArcTan(2)⋅Z)
                Message("Success!");

                // Return ancillas back to |0⟩ state
                ApplyToEach(H, [aux0, aux1]);
            }
        }

        adjoint (...) {
            // We can use the following equation to implement the Adjoint:
            // X exp(i⋅ArcTan(2)⋅Z) X = exp(i⋅ArcTan(2)⋅XZX) = exp(- i⋅ArcTan(2)⋅Z)
            within {
                X(target);
            } apply {
                ExpIZArcTan2NC(target);
            }
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
    operation ExpIZArcTan2PS (target : Qubit) : Unit {

        body (...) {
            using (auxiliaryQubit = Qubit()) {
                // Set ancilla to |+⟩ state
                H(auxiliaryQubit);

                // Note that because T and Z on the target commutes through the control,
                // we can just count the number of T's we need to apply over the course of
                // the protocol and apply one or zero of T's in the end.
                mutable TGatesToApplyInTheEnd = 0;

                repeat {

                    // This is just a log message, so we can see how many times we tried before
                    // succeeding.
                    Message("Trying ...");

                    // we expect to start with auxiliaryQubit being in |+⟩ state
                    AssertMeasurementProbability([PauliX], [auxiliaryQubit], Zero, 1.0, "auxiliaryQubit must be in |+⟩ state", 1E-10);
                    RepeatUntilSuccessStatePreparation(auxiliaryQubit);
                    CNOT(target, auxiliaryQubit);
                    T(auxiliaryQubit);

                    // This is instead of Z(target), T(target)
                    set TGatesToApplyInTheEnd += 5;

                    // The probability to measure |+⟩ on auxiliaryQubit is 5/6
                    AssertMeasurementProbability([PauliX], [auxiliaryQubit], Zero, 5.0 / 6.0, "The probability to measure |+⟩ on auxiliaryQubit must be 5/6", 1E-10);
                    let outcome = Measure([PauliX], [auxiliaryQubit]);
                }
                until (outcome == Zero)
                fixup {

                    // Upon failure the identity gate has been applied to the target qubit
                    // Now let us record the failure to log.
                    Message("We failed. Applying fix-up");

                    // This is instead of Z(target)
                    set TGatesToApplyInTheEnd += 4;

                    // Make sure that auxiliaryQubit is back to |+⟩ state
                    Z(auxiliaryQubit);
                }

                // If outcome is Zero we successfully applied exp(i⋅ArcTan(2)⋅Z)
                Message("Success!");

                // Now apply the required T,S and Z gates.
                // If TGatesToApplyInTheEnd is odd one more T gates is applied, and if
                // TGatesToApplyInTheEnd is even there are no T gates to apply
                // In other words apply exp( i⋅π⋅k/2² |1⟩⟨1| ), where k = TGatesToApplyInTheEnd
                R1Frac(TGatesToApplyInTheEnd, 2, target);

                // Now return the auxiliary qubit to the |0⟩ state
                H(auxiliaryQubit);
            }
        }

        adjoint (...) {
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
    operation RepeatUntilSuccessStatePreparation (target : Qubit) : Unit {
        using (auxiliaryQubit = Qubit()) {
            H(auxiliaryQubit);

            repeat {

                // we expect the target and auxiliary qubits to each be in the |+⟩ state.
                AssertMeasurementProbability([PauliX], [target], Zero, 1.0, "target qubit should be in |+⟩ state", 1E-10);
                AssertMeasurementProbability([PauliX], [auxiliaryQubit], Zero, 1.0, "auxiliaryQubit qubit should be in |+⟩ state", 1E-10);
                Adjoint T(auxiliaryQubit);
                CNOT(target, auxiliaryQubit);
                T(auxiliaryQubit);

                // Probability of measuring |+⟩ state on auxiliaryQubit is 3/4
                AssertMeasurementProbability([PauliX], [auxiliaryQubit], Zero, 3.0 / 4.0, "Error: the probability to measure |+⟩ in the first auxiliaryQubit must be 3/4", 1E-10);

                // if measurement outcome zero we prepared required state
                let outcome = Measure([PauliX], [auxiliaryQubit]);
            }
            until (outcome == Zero)
            fixup {

                // Bring auxiliaryQubit and target back to |+⟩ state
                if (outcome == One) {
                    Z(auxiliaryQubit);
                    X(target);
                    H(target);
                }
            }

            // Return auxiliaryQubit back to Zero state
            H(auxiliaryQubit);
        }
    }

}


