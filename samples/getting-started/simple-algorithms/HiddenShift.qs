// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.SimpleAlgorithms.HiddenShift {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    // We consider a particular family of problems known as hidden
    // shift problems, in which one is given two Boolean functions 𝑓 and 𝑔
    // with the promise that they satisfy the relation
    //
    //     𝑔(𝑥) = 𝑓(𝑥 ⊕ 𝑠) for all 𝑥,
    //
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
    operation HiddenShiftBentCorrelation (Ufstar : (Qubit[] => Unit), Ug : (Qubit[] => Unit), n : Int)
    : Result[] {
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
            return ForEach(MResetZ, qubits);
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
    internal operation ApplyInnerProductBentFunction(u : Int, qs : Qubit[]) : Unit {
        EqualityFactI(Length(qs), 2 * u, "Length of qs must be twice the value of u");

        let xs = qs[0 .. u - 1];
        let ys = qs[u...];

        ApplyToEach(CZ, Zipped(xs, ys));
    }


    // Again, using partial application we create a function which for a given bit
    // size u constructs the IP Boolean function on 2u qubits, computed into the phase.
    function InnerProductBentFunction(u : Int) : (Qubit[] => Unit) {
        return ApplyInnerProductBentFunction(u, _);
    }


    // To instantiate the hidden shift problem we need another function g which is
    // related to IP via g(x) = IP(x + s), i.e., we have to shift the argument of
    // the IP function by a given shift. Notice that the '+' operation here is the
    // Boolean addition, i.e., a bit-wise operation. Notice further, that in
    // general a diagonal operation |x〉 -> (-1)^{f(x)} can be turned into a shifted
    // version by applying a bit flip to the |x〉 register first, then applying the
    // diagonal operation, and then undoing the bit flips to the |x〉 register. We
    // use this principle to define shifted versions of the IP operation.
    internal operation ApplyShiftedInnerProductBentFunction(shift : Bool[], u : Int, qs : Qubit[]) : Unit {
        let n = 2 * u;

        EqualityFactI(
            Length(shift), n, "Length of shift must be twice the value of u");
        EqualityFactI(
            Length(qs), n, "Length of qs must be twice the value of u");

        within {
            // the following loop flips the bits in shift
            ApplyPauliFromBitString(PauliX, true, shift, qs);
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
        return ApplyShiftedInnerProductBentFunction(shift, u, _);
    }
    
    // Run the Hidden Shift algorithm on a given shift and number of qubits
    operation RunHiddenShiftBentCorrelation(patternInt : Int, nQubits : Int) : Result[] {
        let registerSize = nQubits / 2;

        // The integer patternInt is converted to a bit pattern
        // using a canon function (from Utils.qs)
        let pattern = IntAsBoolArray(patternInt, nQubits);

        // We get the HiddenShift result
        return HiddenShiftBentCorrelation(
            InnerProductBentFunction(registerSize),
            ShiftedInnerProductBentFunction(pattern, registerSize),
            nQubits
        );
    }

    // We finish by providing a case that can be easily called from C# or Q#.
    operation RunHiddenShift (shift : Int, nQubits : Int) : Int {
        // Get the result array for a given shift and number of qubits.
        let result = RunHiddenShiftBentCorrelation(shift, nQubits);

        // We then convert back to an integer, so that the C# driver
        // doesn't need to worry with arrays.
        return ResultArrayAsInt(result);
    }
}
