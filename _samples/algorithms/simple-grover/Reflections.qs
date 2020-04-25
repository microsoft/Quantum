// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.SimpleGrover {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;

    /// # Summary
    /// Reflects about the basis state marked by alternating zeros and ones.
    /// This operation defines what input we are trying to find in the main
    /// search.
    operation ReflectAboutMarked(inputQubits : Qubit[]) : Unit {
        Message("Reflecting about marked state...");
        using (outputQubit = Qubit()) {
            within {
                // We initialize the outputQubit to (|0⟩ - |1⟩) / √2,
                // so that toggling it results in a (-1) phase.
                X(outputQubit);
                H(outputQubit);
                // Flip the outputQubit for marked states.
                // Here, we get the state with alternating 0s and 1s by using
                // the X instruction on every other qubit.
                ApplyToEachA(X, inputQubits[...2...]);
            } apply {
                Controlled X(inputQubits, outputQubit);
            }
        }
    }

    /// # Summary
    /// Reflects about the uniform superposition state.
    operation ReflectAboutUniform(inputQubits : Qubit[]) : Unit {
        within {
            // Transform the uniform superposition to all-zero.
            Adjoint PrepareUniform(inputQubits);
            // Transform the all-zero state to all-ones
            PrepareAllOnes(inputQubits);
        } apply {
            // Now that we've transformed the uniform superposition to the
            // all-ones state, reflect about the all-ones state, then let
            // the within/apply block transform us back.
            ReflectAboutAllOnes(inputQubits);
        }
    }

    /// # Summary
    /// Reflects about the all-ones state.
    operation ReflectAboutAllOnes(inputQubits : Qubit[]) : Unit {
        Controlled Z(Most(inputQubits), Tail(inputQubits));
    }

    /// # Summary
    /// Given a register in the all-zeros state, prepares a uniform
    /// superposition over all basis states.
    operation PrepareUniform(inputQubits : Qubit[]) : Unit is Adj + Ctl {
        ApplyToEachCA(H, inputQubits);
    }

    /// # Summary
    /// Given a register in the all-zeros state, prepares an all-ones state
    /// by flipping every qubit.
    operation PrepareAllOnes(inputQubits : Qubit[]) : Unit is Adj + Ctl {
        ApplyToEachCA(X, inputQubits);
    }

}
