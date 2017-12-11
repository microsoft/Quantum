// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Samples.SimpleAlgorithms {
    // Including the namespace Primitive gives access to basic operations such as the 
    // Hadamard gates, CNOT gates, etc. that are useful for defining circuits. The 
    // implementation of these operations is dependent on the targeted machine. 
    open Microsoft.Quantum.Primitive;
    // The canon namespace contains many useful library functions for creating 
    // larger circuits, combinators, and utility functions. The implementation of 
    // the operations in the canon is machine independent as they are built on 
    // top of the primitive operations. 
    open Microsoft.Quantum.Canon;
	// We need symbols one more namespace, namely for the definition of an oracle based 
	// on a list of integers which are used to flip the target qubit when matched. 
    open Microsoft.Quantum.Samples.SimpleAlgorithms;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // This sample contains serveral simple quantum algorithms coded in Q#. The 
    // intent is to highlight the expressive capabilities of the language that 
    // allow to express quantum algirthm that consist of a short quantum part and 
    // classical post-processing that is simple, or in some cases, trivial.

    // First, note that every Q# function needs to have a namespace. We define 
    // a new one for this purpose. 

    //////////////////////////////////////////////////////////////////////////
    // Bernstein–Vazirani Fouier Sampling Quantum Algorithm //////////////////
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
    operation ParityViaFourierSampling(Uf : (Qubit[] => ()), n : Int) : Bool[] { 
        body {
            // We first create an array of size n which will hold the final result.
            mutable resultArray = new Result[n];

            // Now, we allocate n + 1 clean qubits. Note that the function Uf is defined
            // on inputs of the form (x, y), where x has n bits and y has 1 bit.
            using(qubits = Qubit[n + 1]) {
                // The last qubit needs to be flipped so that the function will 
                // actually be computed into the phase when Uf is applied.
                X(qubits[n]);

                // Now, a Hadamard transform is applied to each of the qubits.
                ApplyToEach(H, qubits);

                // We now apply Uf to the n+1 qubits, computing |x, y〉 ↦ |x, y ⊕ f(x)〉.
                Uf(qubits);

                // As the last step before the measurement, a Hadamard transform is 
                // but the very last one. We could apply the Hadamard transform to 
                // the last qubit also, but this would not affect the final outcome. 
                ApplyToEach(H, qubits[0..(n - 1)]); 

                // The following for-loop measures all qubits and resets them to 
                // zero so that they can be safely returned at the end of the 
                // using-block.
                for (idx in 0..(n-1)) {
                    set resultArray[idx] = MResetZ(qubits[idx]);
                }

                // Finally, the last qubit, which held the y-register, is reset. 
                Reset(qubits[n]);							
            }	

            // The result is already contained in resultArray and no further 
            // post-processing is necessary.
            Message($"measured: {resultArray}");
            return BoolArrFromResultArr(resultArray);
         }
    }

    // In order to demonstrate the Bernstein–Vazirani algorithm, we define
    // a function which returns black-box operations (Qubit[] => ()) of
    // the form
    //
    //    U_f |𝑥〉|𝑦〉 = |𝑥〉|𝑦 ⊕ 𝑓(𝑥)〉,
    //
    // as described above.
    
    // In particular, we define 𝑓 by providing the pattern 𝑟⃗. Thus, we can
    // easily assert that the pattern measured by the Bernstein–Vazirani
    // algorithm matches the pattern we used to define 𝑓.

    // As is idiomatic in Q#, we define an operation that we will typically
    // only call by partially applying from within a matching function.
    // To indicate that we are using this idiom, we name the operation
    // with the suffix "Impl", and provide documentation comments for the
    // function itself.    
    operation ParityOperationImpl(pattern : Bool[], qs : Qubit[]) : () {
        body {
            let n = Length(pattern);
            if (Length(qs) != (n + 1)) {
                fail "Length of qs must be equal to n + 1.";
            }
            for (idx in 0..(n-1)) {
                if pattern[idx] {
                    (Controlled X)([qs[idx]], qs[n]);
                }
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
    function ParityOperation(pattern : Bool[]) : (Qubit[] => ()) {
        return ParityOperationImpl(pattern, _);
    }

    // For convienence, we provide an additional operation with a signature
    // that's easy to call from C#. In particular, we define our new operation
    // to take an Int as input and to return an Int as output, where each
    // Int represents a bitstring using the little endian convention.

    operation BernsteinVaziraniTestCase(nQubits : Int, patternInt : Int) : Int {
        body {
            let pattern = BoolArrFromPositiveInt(patternInt, nQubits);
            let result = 
                ParityViaFourierSampling(
                    ParityOperation(pattern), nQubits
                );
            return PositiveIntFromBoolArr(result);
        }
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
    operation IsConstantBooleanFunction(Uf : (Qubit[] => ()), n : Int) : Bool { 
        body {
            // We first create an array of size n from which we compute the final result. 
            mutable resultArray = new Result[n];

            // Now, we allocate n + 1 clean qubits. Note that the function Uf is defined
            // on inputs of the form (x, y), where x has n bits and y has 1 bit.
            using (qubits = Qubit[n + 1]) {

                // The last qubit needs to be flipped so that the function will 
                // actually be computed into the phase when Uf is applied. 
                X(qubits[n]);

                // Now, a Hadamard transform is applied to each of the qubits.
                ApplyToEach(H, qubits);

                // We now apply Uf to the n + 1 qubits, computing |𝑥, 𝑦〉 ↦ |𝑥, 𝑦 ⊕ 𝑓(𝑥)〉.
                Uf(qubits);

                // As the last step before the measurement, a Hadamard transform is 
                // but the very last one. We could apply the Hadamard transform to 
                // the last qubit also, but this would not affect the final outcome. 
                ApplyToEach(H, qubits[0..(n-1)]); 

                // The following for-loop measures all qubits and resets them to 
                // zero so that they can be safely returned at the end of the 
                // using-block.
                for (idx in 0..(n - 1)) {
                    set resultArray[idx] = MResetZ(qubits[idx]);
                }

                // Finally, the last qubit, which held the 𝑦-register, is reset. 
                Reset(qubits[n]);							
            }

            // we use the predicte `IsResultZero` from Microsoft.Quantum.Canon
            // (Predicates.qs) and compose it with the ForAll function from 
            // Microsoft.Quantum.Canon (ForAll.qs). This will return 
            // `true` if the all zero string has been measured, i.e., if the function 
            // was a constant function and `false` if not, which according to the 
            // promise on 𝑓 means that it must have been balanced. 
            return ForAll(IsResultZero, resultArray);
         }
    }

    // As before, we define an operation and a function to construct black-box
    // operations and a test case to make it easier to test Deutsch–Jozsa
    // algorithm from a C# driver.

    operation BooleanFunctionFromMarkedElementsImpl(n : Int, markedElements : Int[], qs : Qubit[]) : () {
		body {
			let target = qs[Length(qs)-1];
			let inputs = qs[0..Length(qs)-2];

            // This operation applies the unitary
            //
            //     𝑈 |𝑧〉 |𝑘〉 = |𝑧 ⊕ 𝑥ₖ〉 |𝑘〉,
            //
            // where 𝑥ₖ = 1 if 𝑘 is an contained in the array markedElements.
            // Operations of this form represent querying "databases" in
            // which some subset of items are marked.
            // We will revisit this construction later, in the DatabaseSearch
            // sample.

            
            let nMarked = Length(markedElements);
            for (idxMarked in 0..nMarked - 1) {
                // Note: As X accepts a Qubit, and ControlledOnInt only 
                // accepts Qubit[], we use ApplyToEachCA(X, _) which accepts 
                // Qubit[] even though the target is only 1 Qubit.
                (ControlledOnInt(markedElements[idxMarked], ApplyToEachCA(X, _)))(inputs, [target]);
            }
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
	function BooleanFunctionFromMarkedElements(nQubits : Int, markedElements : Int[]) : (Qubit[] => ()) {
		return 
			BooleanFunctionFromMarkedElementsImpl(nQubits, markedElements, _ );
	}

    operation DeutschJozsaTestCase(nQubits : Int, markedElements : Int[]) : Bool {
        body {
            return IsConstantBooleanFunction(
				BooleanFunctionFromMarkedElements(nQubits, markedElements),
                nQubits
            );
        }
    }
    
    //////////////////////////////////////////////////////////////////////////
    // Quantum Algorithm for Hidden Shifts of Bent Functions /////////////////
    //////////////////////////////////////////////////////////////////////////

    // We finally consider a particular family of problems known as hidden
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
    operation HiddenShiftBentCorrelation (Ufstar : (Qubit[] => ()), Ug : (Qubit[] => ()), n : Int) : Bool[] { 
        body {
            // we first create an array of size n from which we compute the final result. 
            mutable resultArray = new Result[n];
            // now, we allocate n clean qubits. Note that the function Ufstar and Ug are 
            // unitary operations on n qubits defined via phase encoding.
            using(qubits=Qubit[n]) {				
                // first, a Hadamard transform is applied to each of the qubits.
                ApplyToEach(H, qubits);
                // we now apply the shifted function Ug to the n qubits, computing 
                // |x〉 -> (-1)^{g(x)} |x〉. 
                Ug(qubits);
                // now, a Hadamard transform is applied to each of the n qubits.
                ApplyToEach(H, qubits);
                // we now apply the dual function of the unshifted function, i.e., Ufstar, 
                // to the n qubits, computing |x〉 -> (-1)^{fstar(x)} |x〉.
                Ufstar(qubits);
                // now, a Hadamard transform is applied to each of the n qubits.
                ApplyToEach(H, qubits);
                // the following for-loop measures the n qubits and resets them to 
                // zero so that they can be safely returned at the end of the 
                // using-block.
                for (idx in 0..(n-1)) {
                    set resultArray[idx] = MResetZ(qubits[idx]);
                }
            }	
            // the result is already contained in resultArray and not further 
            // post-processing is necessary except for a conversion from Result[] to 
            // Bool[] for which we use a canon function (from TypeConversion.qs).
            Message($"measured: {resultArray}");
            return BoolArrFromResultArr(resultArray);
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
	//
	// Notice that a diagonal operator implementing IP between 2 variables
	// y_0 and z_0 is nothing but the AND function between those variables, i.e., 
	// in phase encoding it is computed by a Controlled-Z gate. Extending this 
	// to an XOR of the AND of more variables, as required in the definition of 
	// the IP function can then be accomplished by applying several Controlled-Z
	// gates between the respective inputs.
	operation InnerProductBentFunctionImpl(u : Int, qs : Qubit[]) : () {
		body {
			if (Length(qs) != (2*u)) {
				fail "Length of qs must be twice the value of u";
			}
			let xs = qs[0..(u-1)]; 
			let ys = qs[u..(2*u-1)];    
			for (idx in 0..(u-1)) {
				(Controlled Z)([xs[idx]], ys[idx]);
			}
		}
	}

	// Again, using partial application we create a function which for a given bit 
	// size u constructs the IP Boolean function on 2u qubits, computed into the phase.
	function InnerProductBentFunction(u : Int) : (Qubit[] => ()) {
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
	operation ShiftedInnerProductBentFunctionImpl(shift: Bool[], u : Int, qs : Qubit[]) : () {
		body {
			let n = 2 * u;
			if ( (Length(shift) != n) || (Length(qs) != n) ) {
				fail "Length of shift and qs must be twice the value of u";
			}
			// the following loop flips the bits in shift 
			for (idx in 0..(n-1)) {
				if shift[idx] { 
					X(qs[idx]);
				}
			}
			// now we compute the IP function into the phase
			(InnerProductBentFunction(u))(qs);
			// the following loop flips the bits in shift 
			for (idx in 0..(n-1)) {
				if shift[idx] { 
					X(qs[idx]);
				}
			}
		}
	}

	// Again, using partial application we construct a function that produces the 
	// operations that are used to instantiate a particular hidden shift problem 
	// and are then passed to the quantum algorithm `HiddenShiftBentCorrelation`
	// which computes the hidden shift. 
	function ShiftedInnerProductBentFunction(shift : Bool[], u : Int) : (Qubit[] => ()) {
		return ShiftedInnerProductBentFunctionImpl(shift, u, _);
	}

    // We finish by providing a case that can be easily called from C#.

    operation HiddenShiftBentCorrelationTestCase(patternInt : Int, u : Int) : Int {
        body {
            let nQubits = 2 * u;
            // The integer patternInt is converted to a bit pattern
			// using a canon function (from Utils.qs)				
            let pattern = BoolArrFromPositiveInt(patternInt, nQubits);
            // We then convert back to an integer, so that the C# driver
            // doesn't need to worry with arrays.
            let result = PositiveIntFromBoolArr(
                HiddenShiftBentCorrelation(
					InnerProductBentFunction(u), 
					ShiftedInnerProductBentFunction(pattern, u), 
					nQubits
				)
            );

            return result;
        }
    }

}

