// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Examples.Teleportation {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // Quantum teleportation provides a way of moving a quantum state from one 
    // location  to another without having to move physical particle(s) along 
    // with it. This is done with the help of previously shared quantum 
    // entanglement between the sending and the receiving locations and  
    // classical communication.

    //////////////////////////////////////////////////////////////////////////
    // Teleportation /////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // We approach teleportation in two steps. First, we define how to
    // teleport the state of a qubit to another qubit. To do so, we define
    // teleportation as an operation, one of the fundamental building blocks
    // of a Q# program.

    // Most operations which act on qubits to modify their state in some way
    // will not return any useful information to the caller. We represent this
    // by a return value of (), meaning the empty tuple. Since all operations
    // take a tuple and return a tuple, that represents that the return value
    // is unimportant.
    
    /// # Summary
    /// Sends the state of one qubit to a target qubit by using
    /// teleportation.
    ///
    /// # Input
    /// ## msg
    /// A qubit whose state we wish to send.
    /// ## there
    /// A qubit initially in the |0〉 state that we want to send
    /// the state of msg to.
    operation Teleport(msg : Qubit, there : Qubit) : () {
        body {

            using (register = Qubit[1]) {
                // Ask for an auxillary qubit that we can use to prepare
                // for teleportation.
                let here = register[0];
            
                // Create some entanglement that we can use to send our message.
                H(here);
                CNOT(here, there);
            
                // Move our message into the entangled pair.
                CNOT(msg, here);
                H(msg);

                // Measure out the entanglement.
                if (M(msg) == One)  { Z(there); }
                if (M(here) == One) { X(there); }

                // Reset our "here" qubit before releasing it.
                Reset(here);
            }

        }
    }

    // One can use quantum teleportation circuit to send an unobserved
    // (unknown) classical message from source qubit to target qubit
    // by sending specific (known) classical information from source 
    // to target.

    /// # Summary
    /// Uses teleportation to send a classical message from one qubit
    /// to another.
    ///
    /// # Input
    /// ## message
    /// If `true`, the source qubit (`here`) is prepared in the
    /// |1〉 state, otherwise the source qubit is prepared in |0〉.
    ///
    /// ## Output
    /// The result of a Z-basis measurement on the teleported qubit,
    /// represented as a Bool.
    operation TeleportClassicalMessage(message : Bool) : Bool {
        body {
            mutable measurement = false;

            using (register = Qubit[2]) {
                // Ask for some qubits that we can use to teleport.
                let msg = register[0];
                let there = register[1];
                
                // Encode the message we want to send.
                if (message) { X(msg); }
            
                // Use the operation we defined above.
                Teleport(msg, there);

                // Check what message was sent.
                if (M(there) == One) { set measurement = true; }

                // Reset all of the qubits that we used before releasing
                // them.
                ResetAll(register);
            }

            return measurement;
        }
    }

    //////////////////////////////////////////////////////////////////////////
    // Other teleportation scenarios not illustrated here
    //////////////////////////////////////////////////////////////////////////
    //
    // ● Teleport a rotation. Rotate a basis state by a certain angle φ ∈ [0, 2π),
    //   for example by preparing Rₓ(φ) |0〉, and teleport the rotated state to the target qubit.
    //   When successful, the target qubit captures the angle φ [although, on course one does
    //   not have classical access to its value].
    // ● "Super dense coding".  Given an EPR state |β〉 shared between the source and target
    //   qubits, the source can encode two classical bits a,b by applying Z^b X^a to its half
    //   of |β〉. Both bits can be recovered on the target by measurement in the Bell basis.
    //   For details refer to discussion and code in Unit Testing Sample, in file SuperdenseCoding.qs.
    //////////////////////////////////////////////////////////////////////////

}
