// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {

    /// # Summary
    /// Implementation of the first-order Trotter–Suzuki integrator.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type which each time step should act upon; typically, either
    /// `Qubit[]` or `Qubit`.
    ///
    /// # Input
    /// ### nSteps
    /// The number of operations to be decomposed into time steps.
    /// ### op
    /// An operation which accepts an index input (type `Int`) and a time
    /// input (type `Double`) and a quantum register (type `'T`) for decomposition.
    /// ## stepSize
    /// Multiplier on size of each step of the simulation.
    /// ## target
    /// A quantum register on which the operations act.
    ///
    /// # Remarks
    /// ## Example
    /// The following are equivalent:
    /// ```Q#
    /// op(0, deltaT, target);
    /// op(1, deltaT, target);
    ///
    /// Trotter1ImplCA((2, op), deltaT, target);
    /// ```
    operation Trotter1ImplCA<'T>((nSteps : Int, op : ((Int, Double, 'T) => () : Adjoint, Controlled)), stepSize : Double, target : 'T) : () {
        body {
            for(idx in 0..nSteps-1){
                op(idx, stepSize, target);
            }
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Implementation of the second-order Trotter–Suzuki integrator.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type which each time step should act upon; typically, either
    /// `Qubit[]` or `Qubit`.
    ///
    /// # Input
    /// ### nSteps
    /// The number of operations to be decomposed into time steps.
    /// ### op
    /// An operation which accepts an index input (type `Int`) and a time
    /// input (type `Double`) and a quantum register (type `'T`) for decomposition.
    /// ## stepSize
    /// Multiplier on size of each step of the simulation.
    /// ## target
    /// A quantum register on which the operations act.
    ///
    /// # Remarks
    /// ## Example
    /// The following are equivalent:
    /// ```Q#
    /// op(0, deltaT / 2.0, target);
    /// op(1, deltaT / 2.0, target);
    /// op(1, deltaT / 2.0, target);
    /// op(0, deltaT / 2.0, target);
    ///
    /// Trotter2ImplCA((2, op), deltaT, target);
    /// ```
    operation Trotter2ImplCA<'T>((nSteps : Int, op : ((Int, Double, 'T) => () : Adjoint, Controlled)), stepSize : Double, target : 'T) : () {
        body {
            for(idx in 0..nSteps-1){
                op(idx, stepSize * 0.5, target);
            }
            for(idx in (nSteps-1)..(-1)..0){
                op(idx, stepSize * 0.5, target);
            }
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Returns an operation implementing the Trotter–Suzuki integrator for
    /// a given operation.
    ///
    /// # Type Parameters
    /// ## 'T
    /// The type which each time step should act upon; typically, either
    /// `Qubit[]` or `Qubit`.
    ///
    /// # Input
    /// ### nSteps
    /// The number of operations to be decomposed into time steps.
    /// ### op
    /// An operation which accepts an index input (type `Int`) and a time
    /// input (type `Double`) for decomposition.
    /// ## trotterOrder
    /// Selects the order of the Trotter–Suzuki integrator to be used.
    /// Order 1 and 2 are currently supported.
    ///
    /// # Output
    /// Returns a unitary implementing the Trotter–Suzuki integrator, where
    /// the first parameter `Double` is the integration step size, and the
    /// second parameter is the target acted upon.
    function DecomposeIntoTimeStepsCA<'T>((nSteps : Int, op : ((Int, Double, 'T) => () : Adjoint, Controlled)), trotterOrder : Int) : ((Double, 'T) => () : Adjoint, Controlled) {
        if (trotterOrder == 1) {
            return Trotter1ImplCA((nSteps, op), _, _);
        } elif (trotterOrder == 2) {
            return Trotter2ImplCA((nSteps, op), _, _);
        } else {
            fail "Order $order not yet supported.";
        }

        // Needed so we have a return value of the right type in all cases, but
        //        this line is unreachable.
        return Trotter1ImplCA((nSteps, op), _, _);
    }
}
