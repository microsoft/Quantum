// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// Reflects about the uniform superposition state.
    ///
    /// # Input
    /// ## inputQubits
    /// The register whose state is to be reflected.
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
    ///
    /// # Input
    /// ## inputQubits
    /// The register whose state is to be reflected.
    operation ReflectAboutAllOnes(inputQubits : Qubit[]) : Unit {
        Controlled Z(Most(inputQubits), Tail(inputQubits));
    }

    /// # Summary
    /// Given a register in the all-zeros state, prepares a uniform
    /// superposition over all basis states.
    ///
    /// # Input
    /// ## inputQubits
    /// The register to be prepared in a uniform superposition.
    operation PrepareUniform(inputQubits : Qubit[]) : Unit is Adj + Ctl {
        ApplyToEachCA(H, inputQubits);
    }

    /// # Summary
    /// Given a register in the all-zeros state, prepares an all-ones state
    /// by flipping every qubit.
    ///
    /// # Input
    /// ## inputQubits
    /// The register to be prepared in the all-ones state.
    operation PrepareAllOnes(inputQubits : Qubit[]) : Unit is Adj + Ctl {
        ApplyToEachCA(X, inputQubits);
    }

}
