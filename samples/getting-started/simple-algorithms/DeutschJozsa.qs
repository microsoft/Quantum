// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


// First, note that every Q# function must have a namespace. We define
// a new one for this purpose.
namespace Microsoft.Quantum.Samples.SimpleAlgorithms.DeutschJozsa {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;

    //////////////////////////////////////////////////////////////////////////
    // Deutsch–Jozsa Quantum Algorithm ///////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// Deutsch–Jozsa is a quantum algorithm that decides whether a given Boolean function
    /// 𝑓 that is promised to either be constant or to be balanced — i.e., taking the
    /// values 0 and 1 the exact same number of times — is actually constant or balanced.
    /// The operation `IsConstantBooleanFunction` answers this question by returning the
    /// Boolean value `true` if the function is constant and `false` if it is not. Note
    /// that the promise that the function is either constant or balanced is assumed.
    ///
    /// # Input
    /// ## Uf
    /// A quantum operation that implements |𝑥〉|𝑦〉 ↦ |𝑥〉|𝑦 ⊕ 𝑓(𝑥)〉,
    /// where 𝑓 is a Boolean function, 𝑥 is an 𝑛 bit register and 𝑦 is a single qubit.
    /// ## n
    /// The number of bits of the input register |𝑥〉.
    ///
    /// # Output
    /// A boolean value `true` that indicates that the function is constant and `false`
    /// that indicates that the function is balanced.
    ///
    /// # See Also
    /// - For details see Section 1.4.3 of Nielsen & Chuang.
    ///
    /// # References
    /// - [ *Michael A. Nielsen , Isaac L. Chuang*,
    ///     Quantum Computation and Quantum Information ](http://doi.org/10.1017/CBO9780511976667)
    operation IsConstantBooleanFunction (Uf : ((Qubit[], Qubit) => Unit), n : Int) : Bool {
        // Now, we allocate n + 1 clean qubits. Note that the function Uf is defined
        // on inputs of the form (x, y), where x has n bits and y has 1 bit.
        using ((queryRegister, target) = (Qubit[n], Qubit())) {
            // The last qubit needs to be flipped so that the function will
            // actually be computed into the phase when Uf is applied.
            X(target);
            H(target);

            within {
                // Now, a Hadamard transform is applied to each of the qubits.
                // As the last step before the measurement, a Hadamard transform is
                // but the very last one. We could apply the Hadamard transform to
                // the last qubit also, but this would not affect the final outcome.
                // We use a within-apply block to ensure that the Hadamard transform is
                // correctly inverted.
                ApplyToEachA(H, queryRegister);
            } apply {
                // We now apply Uf to the n + 1 qubits, computing |𝑥, 𝑦〉 ↦ |𝑥, 𝑦 ⊕ 𝑓(𝑥)〉.
                Uf(queryRegister, target);
            }

            // The following for-loop measures all qubits and resets them to
            // zero so that they can be safely returned at the end of the
            // using-block.
            let resultArray = ForEach(MResetZ, queryRegister);

            // Finally, the last qubit, which held the 𝑦-register, is reset.
            Reset(target);

            // We use the predicate `IsResultZero` from Microsoft.Quantum.Canon
            // and compose it with the All function from
            // Microsoft.Quantum.Arrays. This will return
            // `true` if the all zero string has been measured, i.e., if the function
            // was a constant function and `false` if not, which according to the
            // promise on 𝑓 means that it must have been balanced.
            return All(IsResultZero, resultArray);
        }
    }



    // As before, we define an operation and a function to construct black-box
    // operations and a test case to make it easier to test Deutsch–Jozsa
    // algorithm from a C# driver.
    internal operation BooleanFunctionFromMarkedElementsImpl(n : Int, markedElements : Int[], query : Qubit[], target : Qubit) : Unit {
        // This operation applies the unitary

        //     𝑈 |𝑧〉 |𝑘〉 = |𝑧 ⊕ 𝑥ₖ〉 |𝑘〉,

        // where 𝑥ₖ = 1 if 𝑘 is an contained in the array markedElements.
        // Operations of this form represent querying "databases" in
        // which some subset of items are marked.
        // We will revisit this construction later, in the DatabaseSearch
        // sample.
        for (markedElement in markedElements) {
            // Note: As X accepts a Qubit, and ControlledOnInt only
            // accepts Qubit[], we use ApplyToEachCA(X, _) which accepts
            // Qubit[] even though the target is only 1 Qubit.
            (ControlledOnInt(markedElement, ApplyToEachCA(X, _)))(query, [target]);
        }
    }


    /// # Summary
    /// Constructs an operation representing a query to a boolean function
    /// 𝑓(𝑥⃗) for a bitstring 𝑥⃗, such that 𝑓(𝑥⃗) = 1 if and only if the integer
    /// 𝑘 represented by 𝑥⃗ is an element of a given array.
    ///
    /// # Input
    /// ## nQubits
    /// The number of qubits to be used in representing the query operation.
    /// ## markedElements
    /// An array of the elements {𝑘ᵢ} for which 𝑓 should return 1.
    ///
    /// # Output
    /// An operation representing the unitary 𝑈 |𝑧〉 |𝑘〉 = |𝑧 ⊕ 𝑥ₖ〉 |𝑘〉.
    function BooleanFunctionFromMarkedElements (nQubits : Int, markedElements : Int[]) : ((Qubit[], Qubit) => Unit) {
        return BooleanFunctionFromMarkedElementsImpl(nQubits, markedElements, _, _);
    }


    operation RunDeutschJozsa(nQubits : Int, markedElements : Int[]) : Bool {
        return IsConstantBooleanFunction(
            BooleanFunctionFromMarkedElements(nQubits, markedElements),
            nQubits
        );
    }
}
