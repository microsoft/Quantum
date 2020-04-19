// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


// First, note that every Q# function must have a namespace. We define
// a new one for this purpose.
namespace Microsoft.Quantum.Samples.SimpleAlgorithms {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;


    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // This sample contains several simple quantum algorithms coded in Q#. The
    // intent is to highlight the expressive capabilities of the language that
    // enable it to express quantum algorithms that consist of a short quantum
    // part and classical post-processing that is simple, or in some cases,
    // trivial.

    //////////////////////////////////////////////////////////////////////////
    // Bernstein–Vazirani Fourier Sampling Quantum Algorithm //////////////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// ParityViaFourierSampling implements the Bernstein-Vazirani quantum algorithm.
    /// This algorithm computes for a given Boolean function that is promised to be
    /// a parity 𝑓(𝑥₀, …, 𝑥ₙ₋₁) = Σᵢ 𝑟ᵢ 𝑥ᵢ a result in form of
    /// a bit vector (𝑟₀, …, 𝑟ₙ₋₁) corresponding to the parity function.
    /// Note that it is promised that the function is actually a parity function.
    ///
    /// # Input
    /// ## Uf
    /// A quantum operation that implements |𝑥〉|𝑦〉 ↦ |𝑥〉|𝑦 ⊕ 𝑓(𝑥)〉,
    /// where 𝑓 is a Boolean function that implements a parity Σᵢ 𝑟ᵢ 𝑥ᵢ.
    /// ## n
    /// The number of bits of the input register |𝑥〉.
    ///
    /// # Output
    /// An array of type `Bool[]` that contains the parity 𝑟⃗ = (𝑟₀, …, 𝑟ₙ₋₁).
    ///
    /// # See Also
    /// - For details see Section 1.4.3 of Nielsen & Chuang.
    ///
    /// # References
    /// - [ *Ethan Bernstein and Umesh Vazirani*,
    ///     SIAM J. Comput., 26(5), 1411–1473, 1997 ](https://doi.org/10.1137/S0097539796300921)
    operation ParityViaFourierSampling(Uf : ((Qubit[], Qubit) => Unit), n : Int) : Bool[] {
        // Now, we allocate n + 1 clean qubits. Note that the function Uf is defined
        // on inputs of the form (x, y), where x has n bits and y has 1 bit.
        using ((queryRegister, target) = (Qubit[n], Qubit())) {
            // The last qubit needs to be flipped so that the function will
            // actually be computed into the phase when Uf is applied.
            X(target);

            within {
                // Now, a Hadamard transform is applied to each of the qubits.
                // As the last step before the measurement, a Hadamard transform is
                // applied to all qubits except last one. We could apply the transform to
                // the last qubit also, but this would not affect the final outcome.
                // We use a within-apply block to ensure that the Hadmard transform is
                // correctly inverted.
                ApplyToEachA(H, queryRegister);
            } apply {
                H(target);
                // We now apply Uf to the n+1 qubits, computing |x, y〉 ↦ |x, y ⊕ f(x)〉.
                Uf(queryRegister, target);
            }

            // The following for-loop measures all qubits and resets them to
            // zero so that they can be safely returned at the end of the
            // using-block.
            let resultArray = ForEach(MResetZ, queryRegister);

            // The result is already contained in resultArray so no further
            // post-processing is necessary.
            Message($"measured: {resultArray}");

            // Finally, the last qubit, which held the y-register, is reset.
            Reset(target);
            return ResultArrayAsBoolArray(resultArray);
        }
    }


    // To demonstrate the Bernstein–Vazirani algorithm, we define
    // a function which returns black-box operations (Qubit[] => ()) of
    // the form

    //    U_f |𝑥〉|𝑦〉 = |𝑥〉|𝑦 ⊕ 𝑓(𝑥)〉,

    // as described above.

    // In particular, we define 𝑓 by providing the pattern 𝑟⃗. Thus, we can
    // easily assert that the pattern measured by the Bernstein–Vazirani
    // algorithm matches the pattern we used to define 𝑓.

    // As is idiomatic in Q#, we define an operation that we will typically
    // only call by partially applying it from within a matching function.
    // To indicate that we are using this idiom, we name the operation
    // with an initial underscore to mark it as private, and provide
    // documentation comments for the function itself.
    operation _ParityOperation(pattern : Bool[], queryRegister : Qubit[], target : Qubit) : Unit {
        if (Length(queryRegister) != Length(pattern)) {
            fail "Length of input register must be equal to the pattern length.";
        }

        for ((patternBit, controlQubit) in Zip(pattern, queryRegister)) {
            if (patternBit) {
                Controlled X([controlQubit], target);
            }
        }
    }


    /// # Summary
    /// Given a bitstring 𝑟⃗ = (r₀, …, rₙ₋₁), returns an operation implementing
    /// a unitary 𝑈 that acts on 𝑛 + 1 qubits as
    ///
    ///       𝑈 |𝑥〉|𝑦〉 = |𝑥〉|𝑦 ⊕ 𝑓(𝑥)〉,
    /// where 𝑓(𝑥) = Σᵢ 𝑥ᵢ 𝑟ᵢ mod 2.
    ///
    /// # Input
    /// ## pattern
    /// The bitstring 𝑟⃗ used to define the function 𝑓.
    ///
    /// # Output
    /// An operation implementing 𝑈.
    function ParityOperation(pattern : Bool[]) : ((Qubit[], Qubit) => Unit) {
        return _ParityOperation(pattern, _, _);
    }


    // For convenience, we provide an additional operation with a signature
    // that's easy to call from C#. In particular, we define our new operation
    // to take an Int as input and to return an Int as output, where each
    // Int represents a bitstring using the little endian convention.
    operation BernsteinVaziraniTestCase (nQubits : Int, patternInt : Int) : Int {
        let pattern = IntAsBoolArray(patternInt, nQubits);
        let result = ParityViaFourierSampling(ParityOperation(pattern), nQubits);
        return BoolArrayAsInt(result);
    }


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
                // We use a within-apply block to ensure that the Hadmard transform is
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

            // We use the predicte `IsResultZero` from Microsoft.Quantum.Canon
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
    operation _BooleanFunctionFromMarkedElements(n : Int, markedElements : Int[], query : Qubit[], target : Qubit) : Unit {
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
        return _BooleanFunctionFromMarkedElements(nQubits, markedElements, _, _);
    }


    operation DeutschJozsaTestCase(nQubits : Int, markedElements : Int[]) : Bool {
        return IsConstantBooleanFunction(
            BooleanFunctionFromMarkedElements(nQubits, markedElements),
            nQubits
        );
    }


    //////////////////////////////////////////////////////////////////////////
    // Quantum Algorithm for Hidden Shifts of Bent Functions /////////////////
    //////////////////////////////////////////////////////////////////////////

    // We finally consider a particular family of problems known as hidden
    // shift problems, in which one is given two Boolean functions 𝑓 and 𝑔
    // with the promise that they satisfy the relation

    //     𝑔(𝑥) = 𝑓(𝑥 ⊕ 𝑠) for all 𝑥,

    // where 𝑠 is a hidden bitstring that we would like to find.

    // Good quantum algorithms exist for several different families of
    // pairs of Boolean functions. In particular, here we consider the case
    // in which both 𝑓 and 𝑔 are bent functions. We say that a Boolean
    // function is bent if it is as far from linear as possible. In
    // particular, bent functions have flat Fourier spectra, such that each
    // Fourier coefficient is equal in absolute value.

    // In this case, the Roetteler algorithm (see References, below) uses
    // black-box oracles for 𝑓^* and 𝑔, where 𝑓^* is the dual bent function
    // to 𝑓 (defined in more detail below), and computes the hidden shift 𝑠
    // between 𝑓 and 𝑔.

    /// # Summary
    /// Correlation-based algorithm to solve the hidden shift problem for bent functions.
    /// The problem is to identify an unknown shift 𝑠 of the arguments of two Boolean functions
    /// 𝑓 and 𝑔 that are promised to satisfy the relation 𝑔(𝑥) = 𝑓(𝑥 ⊕ 𝑠) for all 𝑥.
    /// Note that the promise about the functions 𝑓 and 𝑔 to be bent functions is assumed,
    /// i.e., they both have a flat Fourier (Walsh–Hadamard) spectra. Input to this algorithm
    /// are implementations 𝑈_g of the Boolean function 𝑔 and 𝑈_f^*, an implementation of
    /// dual bent function of the function 𝑓. Both functions are given via phase encoding.
    ///
    /// # Input
    /// ## Ufstar
    /// A quantum operation that implements $U_f^*:\ket{x}\mapsto (-1)^{f^*(x)} \ket{x}$,
    /// where $f^*$ is a Boolean function, $x$ is an $n$ bit register and $y$ is a single qubit.
    /// ## Ug
    /// A quantum operation that implements $U_g:\ket{x}\mapsto (-1)^{g(x)} \ket{x}$,
    /// where $g$ is a Boolean function that is shifted by unknown $s$ from $f$, and $x$ is
    /// an $n$ bit register.
    /// ## n
    /// The number of bits of the input register |𝑥〉.
    ///
    /// # Output
    /// An array of type `Bool[]` which encodes the bit representation of the hidden shift.
    ///
    /// # References
    /// - [*Martin Roetteler*,
    ///    Proc. SODA 2010, ACM, pp. 448-457, 2010](https://doi.org/10.1137/1.9781611973075.37)
    operation HiddenShiftBentCorrelation (Ufstar : (Qubit[] => Unit), Ug : (Qubit[] => Unit), n : Int) : Bool[] {
        // now, we allocate n clean qubits. Note that the function Ufstar and Ug are
        // unitary operations on n qubits defined via phase encoding.
        using (qubits = Qubit[n]) {
            // first, a Hadamard transform is applied to each of the qubits.
            ApplyToEach(H, qubits);

            // we now apply the shifted function Ug to the n qubits, computing
            // |x〉 -> (-1)^{g(x)} |x〉.
            Ug(qubits);

            within {
                // now, a Hadamard transform is applied to each of the n qubits.
                ApplyToEachA(H, qubits);
            } apply {
                // we now apply the dual function of the unshifted function, i.e., Ufstar,
                // to the n qubits, computing |x〉 -> (-1)^{fstar(x)} |x〉.
                Ufstar(qubits);
            }

            // the following for-loop measures the n qubits and resets them to
            // zero so that they can be safely returned at the end of the
            // using-block.
            let resultArray = ForEach(MResetZ, qubits);
            // the result is already contained in resultArray and not further
            // post-processing is necessary except for a conversion from Result[] to
            // Bool[] for which we use a canon function (from TypeConversion.qs).
            Message($"measured: {resultArray}");
            return ResultArrayAsBoolArray(resultArray);
        }
    }


    // We demonstrate this algorithm by defining an operation which implements
    // an oracle for a bent function constructed from the inner product of
    // Boolean functions.

    // In particular, the operation `InnerProductBentFunctionImpl` defines the Boolean
    // function IP(x_0, ..., x_{n-1}) which is computed into the phase, i.e.,
    // a diagonal operator that maps |x〉 -> (-1)^{IP(x)} |x〉, where x stands for
    // x = (x_0, ..., x_{n-1}) and all the x_i are binary. The IP function is
    // defined as IP(y, z) = y_0 z_0 + y_1 z_1 + ... y_{u-1} z_{u-1} where
    // y = (y_0, ..., y_{u-1}) and z =  (z_0, ..., z_{u-1}) are two bit
    // vectors of length u. Notice that the function IP is a Boolean function
    // on n = 2u bits. IP is a special case of a so-called 'bent' function.
    // These are functions for which the Walsh-Hadamard transform is perfectly
    // flat (in absolute value). Because of this flatness, the Walsh-Hadamard
    // spectrum of any bent function defines a +1/-1 function, i.e., gives
    // rise to another Boolean function, called the 'dual bent function'.
    // What is more, for the case of the IP function it can be shown that IP
    // is equal to its own dual bent function, a fact that is exploited in
    // the present test case.

    // Notice that a diagonal operator implementing IP between 2 variables
    // y_0 and z_0 is nothing but the AND function between those variables, i.e.,
    // in phase encoding it is computed by a Controlled-Z gate. Extending this
    // to an XOR of the AND of more variables, as required in the definition of
    // the IP function can then be accomplished by applying several Controlled-Z
    // gates between the respective inputs.
    operation InnerProductBentFunctionImpl (u : Int, qs : Qubit[]) : Unit {

        if (Length(qs) != 2 * u) {
            fail "Length of qs must be twice the value of u";
        }

        let xs = qs[0 .. u - 1];
        let ys = qs[u .. 2 * u - 1];

        for (idx in 0 .. u - 1) {
            Controlled Z([xs[idx]], ys[idx]);
        }
    }


    // Again, using partial application we create a function which for a given bit
    // size u constructs the IP Boolean function on 2u qubits, computed into the phase.
    function InnerProductBentFunction(u : Int) : (Qubit[] => Unit) {
        return InnerProductBentFunctionImpl(u, _);
    }


    // To instantiate the hidden shift problem we need another function g which is
    // related to IP via g(x) = IP(x + s), i.e., we have to shift the argument of
    // the IP function by a given shift. Notice that the '+' operation here is the
    // Boolean addition, i.e., a bit-wise operation. Notice further, that in
    // general a diagonal operation |x〉 -> (-1)^{f(x)} can be turned into a shifted
    // version by applying a bit flip to the |x〉 register first, then applying the
    // diagonal operation, and then undoing the bit flips to the |x〉 register. We
    // use this principle to define shifted versions of the IP operation.
    operation _ShiftedInnerProductBentFunction(shift : Bool[], u : Int, qs : Qubit[]) : Unit {
        let n = 2 * u;

        if (Length(shift) != n or Length(qs) != n) {
            fail "Length of shift and qs must be twice the value of u";
        }

        within {
            // the following loop flips the bits in shift
            for ((shiftBit, target) in Zip(shift, qs)) {
                if (shiftBit) {
                    X(target);
                }
            }
        } apply {
            // now we compute the IP function into the phase
            (InnerProductBentFunction(u))(qs);
        }
    }


    // Again, using partial application we construct a function that produces the
    // operations that are used to instantiate a particular hidden shift problem
    // and are then passed to the quantum algorithm `HiddenShiftBentCorrelation`
    // which computes the hidden shift.
    function ShiftedInnerProductBentFunction(shift : Bool[], u : Int) : (Qubit[] => Unit) {
        return _ShiftedInnerProductBentFunction(shift, u, _);
    }


    // We finish by providing a case that can be easily called from C#.
    operation HiddenShiftBentCorrelationTestCase (patternInt : Int, u : Int) : Int {
        let nQubits = 2 * u;

        // The integer patternInt is converted to a bit pattern
        // using a canon function (from Utils.qs)
        let pattern = IntAsBoolArray(patternInt, nQubits);

        // We then convert back to an integer, so that the C# driver
        // doesn't need to worry with arrays.
        let result = BoolArrayAsInt(
            HiddenShiftBentCorrelation(
                InnerProductBentFunction(u),
                ShiftedInnerProductBentFunction(pattern, u),
                nQubits
            )
        );
        return result;
    }

}
