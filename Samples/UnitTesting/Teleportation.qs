// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Circuit for teleportation with detailed annotation of measurement probabilities
    ///////////////////////////////////////////////////////////////////////////////////////////////


	/// # Summary
	/// Teleportation transfers 1 qubit by encoding it into a 2-bit message,
	/// using an entangled pair of qubits.
    ///
    /// # Remarks
    ///	Always returns source qubit to |0⟩.
	///
	/// The circuit first creates an EPR pair between the target qubit and
	/// an ancilla qubit that gets allocated inside the function. Then a
	/// Bell measurement between the source qubit and one half of the EPR
	/// pair is performed. Finally, depending on the 4 possible outcomes of
	/// the Bell measurement, a correction is performed to restore the state
	/// in the target qubit.
	///
    /// # Input
	/// ## source
    /// A single qubit representing the state to be teleported.
	/// ## target
    /// A single qubit initially in the |0⟩ state onto which
	/// given state is to be teleported.
    ///
    /// # See Also
    /// - For details see Section 1.3.6 of Nielsen & Chuang
    ///
    /// # References
    /// - [ *Michael A. Nielsen , Isaac L. Chuang*,
    ///     Quantum Computation and Quantum Information ](http://doi.org/10.1017/CBO9780511976667)
    operation Teleportation (source : Qubit, target : Qubit) : () {
        body {
            // Get a temporary qubit for the Bell pair.
            using (ancillaRegister = Qubit[1]) {
                let ancilla = ancillaRegister[0];
            
                // Create a Bell pair between the temporary qubit and the target.
                Assert(
                    [PauliZ], [target], Zero, 
                    "Error: target qubit must be initialized in zero state");

                H(ancilla);
                CNOT(ancilla, target);
                Assert(
                    [PauliZ; PauliZ], [ancilla; target], Zero, 
                    "Error: EPR state must be eigenstate of ZZ");
                Assert(
                    [PauliX; PauliX], [ancilla; target], Zero, 
                    "Error: EPR state must be eigenstate of XX");
            
                // Perform the Bell measurement and the correction necessary to
				// reconstruct the input state as the target state.
                CNOT(source, ancilla);
                H(source);
                AssertProb(
                    [PauliZ], [source], Zero, 0.5,
                    "Error: All outcomes of the Bell measurement must be equally likely", 1e-5);
                
                // Note that MResetZ makes sure that source is returned to zero state
				// so that we can deallocate it.
                if (MResetZ(source) == One)  { Z(target); }

                // The probability of measuring 0 or 1 is independent on the previous 
                // measurement outcome
                AssertProb(
                    [PauliZ], [ancilla], Zero, 0.5,
                    "Error: All outcomes of the Bell measurement must be equally likely", 1e-5);

				if (MResetZ(ancilla) == One) { X(target); }
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Other teleportation circuits not illustrated here
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // 
    // ● Constant depth remote teleportation in linear nearest neighbor architecture.
    //   For a circuit diagram see Figure 3 on
    //   [Page 7 of arXiv:1207.6655v2](https://arxiv.org/pdf/1207.6655v2.pdf#page=7)
    //
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
