// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples {
    /// # Summary
    /// A simulator-specific operation to specify a picture scope.
    ///
    /// # Description
    /// The scope is opened with a standard call to the operation
    /// and closed with an `Adjoint` call to the operation.
    ///
    /// # Example
    /// Saves ⟨q|pic⟩ commands into `filename.qpic`
    /// ```Q#
    /// within { SavePicture("filename.qpic"); }
    /// apply {
    ///   using ((a, b) = (Qubit(), Qubit())) {
    ///     H(a);
    ///     CNOT(a, b);
    ///   }
    /// }
    /// ```
    operation SavePicture(filename : String) : Unit is Adj {
    }

    /// # Summary
    /// A simulator-specific operation to add a ⟨q|pic⟩ BARRIER command.
    operation Barrier() : Unit {
    }
}
