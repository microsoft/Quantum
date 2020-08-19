// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//////////////////////////////////////////////////////////////////////////
// Introduction //////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// This sample contains several simple quantum algorithms coded in Q#. The
// intent is to highlight the expressive capabilities of the language that
// enable it to express quantum algorithms that consist of a short quantum
// part and classical post-processing that is simple, or in some cases,
// trivial.

namespace Microsoft.Quantum.Samples.SimpleAlgorithms {

    open Microsoft.Quantum.Arrays as Array;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Samples.SimpleAlgorithms.HiddenShift;
    open Microsoft.Quantum.Samples.SimpleAlgorithms.DeutschJozsa;
    open Microsoft.Quantum.Samples.SimpleAlgorithms.BernsteinVazirani;

    @EntryPoint()
    operation RunProgram (nQubits : Int) : Unit {
        
        // Parity Sampling with the Bernstein–Vazirani Algorithm:

        // Consider a function 𝑓(𝑥⃗) on bitstrings 𝑥⃗ = (𝑥₀, …, 𝑥ₙ₋₁) of the
        // form
        //
        //     𝑓(𝑥⃗) ≔ Σᵢ 𝑥ᵢ 𝑟ᵢ
        //
        // where 𝑟⃗ = (𝑟₀, …, 𝑟ₙ₋₁) is an unknown bitstring that determines
        // the parity of 𝑓.

        // The Bernstein–Vazirani algorithm allows determining 𝑟 given a
        // quantum operation that implements
        //
        //     |𝑥〉|𝑦〉 ↦ |𝑥〉|𝑦 ⊕ 𝑓(𝑥)〉.
        //
        // In SimpleAlgorithms.qs, we implement this algorithm as the
        // operation RunBernsteinVazirani. This operation takes an
        // integer whose bits describe 𝑟, then uses those bits to
        // construct an appropriate operation, and finally measures 𝑟.

        // We call that operation here, ensuring that we always get the
        // same value for 𝑟 that we provided as input.

        for (parity in 0 .. (1 <<< nQubits) - 1)
        {
            let measuredParity = RunBernsteinVazirani(nQubits, parity);
            if (measuredParity != parity) {
                fail $"Measured parity {measuredParity}, but expected {parity}.";
            }
        }

        Message("All parities measured successfully!");

        // Constant versus Balanced Functions with the Deutsch–Jozsa Algorithm:

        // A Boolean function is a function that maps bitstrings to a
        // bit,
        //
        //     𝑓 : {0, 1}^n → {0, 1}.
        //
        // We say that 𝑓 is constant if 𝑓(𝑥⃗) = 𝑓(𝑦⃗) for all bitstrings
        // 𝑥⃗ and 𝑦⃗, and that 𝑓 is balanced if 𝑓 evaluates to true (1) for
        // exactly half of its inputs.

        // If we are given a function 𝑓 as a quantum operation 𝑈 |𝑥〉|𝑦〉
        // = |𝑥〉|𝑦 ⊕ 𝑓(𝑥)〉, and are promised that 𝑓 is either constant or
        // is balanced, then the Deutsch–Jozsa algorithm decides between
        // these cases with a single application of 𝑈.

        // In SimpleAlgorithms.qs, we implement this algorithm as
        // RunDeutschJozsa, following the pattern above.
        // This time, however, we will pass an array to Q# indicating
        // which elements of 𝑓 are marked; that is, should result in true.
        // We check by ensuring that RunDeutschJozsa returns true
        // for constant functions and false for balanced functions.

        let elements = nQubits > 0 ? Array.SequenceI(0, (1 <<< nQubits) - 1) | new Int[0];
        if (RunDeutschJozsa(nQubits, elements[...2...])) {
            fail "Measured that test case {balancedTestCase} was constant!";
        }

        if (not RunDeutschJozsa(nQubits, elements))
        {
            fail "Measured that test case {constantTestCase} was balanced!";
        }

        Message("Both constant and balanced functions measured successfully!");

        // Finding Hidden Shifts of Bent Functions with the Roetteler Algorithm:

        // Finally, we consider the case of finding a hidden shift 𝑠
        // between two Boolean functions 𝑓(𝑥) and 𝑔(𝑥) = 𝑓(𝑥 ⊕ 𝑠).
        // This problem can be solved on a quantum computer with one call
        // to each of 𝑓 and 𝑔 in the special case that both functions are
        // bent; that is, that they are as far from linear as possible.

        // Here, we run the test case HiddenShiftBentCorrelationTestCase
        // defined in the matching Q# source code, and ensure that it
        // correctly finds each hidden shift for a family of bent
        // functions defined by the inner product.

        for (shift in 0 .. (1 <<< nQubits) - 1)
        {
            let measuredShift = RunHiddenShift(shift, nQubits);
            if (measuredShift != shift) {
                fail $"Measured shift {measuredShift}, but expected {shift}.";
            }
        }

        Message("Measured hidden shifts successfully!");
    }
}
