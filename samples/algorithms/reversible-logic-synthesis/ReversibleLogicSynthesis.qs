// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.ReversibleLogicSynthesis {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Synthesis;

    ////////////////////////////////////////////////////////////
    // Example program to synthesize a permutation            //
    ////////////////////////////////////////////////////////////

    /// # Summary
    /// Takes as input a permutation, finds a quantum circuit using
    /// transformation-based synthesis, and checks whether the circuit realizes
    /// the input permutation.
    ///
    /// # Remarks
    /// Details on reversible logic synthesis and the operation
    /// that applies a permutation to the quantum state can be found
    /// in the Q# Standard library:
    /// https://github.com/microsoft/QuantumLibraries/blob/main/Standard/src/Synthesis/TransformationBased.qs
    ///
    /// # Input
    /// ## perm
    /// A permutation of 2^𝑛 elements starting from 0.
    ///
    /// # Output
    /// True, if the circuit correctly implements the permutation.
    operation SimulatePermutation(perm : Int[]) : Bool {
        mutable result = true;
        let nbits = BitSizeI(Length(perm) - 1);
        for (i in IndexRange(perm)) {
            using (qubits = Qubit[nbits]) {
                ApplyXorInPlace(i, LittleEndian(qubits));
                ApplyPermutationUsingTransformation(perm, LittleEndian(qubits));
                let simres = MeasureInteger(LittleEndian(qubits));

                if (simres != perm[i]) {
                    set result = false;
                }
            }
        }

        return result;
    }


    ////////////////////////////////////////////////////////////
    // Hidden shift problem using permutation and             //
    // inner product                                          //
    ////////////////////////////////////////////////////////////

    /// # Summary
    /// Computes the inner product using controlled Z gates.
    ///
    /// # Input
    /// ## qubits
    /// An array of an even number of qubits.  The function pairs qubits from
    /// the first half of the array with the second half of the array.
    operation ComputeInnerProduct(qubits : Qubit[]) : Unit {
        let m = Length(qubits) / 2;
        ApplyToEach(CZ, Zipped(qubits[0..m - 1], qubits[m..Length(qubits) - 1]));
    }


    /// # Summary
    /// Applies shift (+s) to array of qubits using Pauli X gates.
    ///
    /// A Pauli X gate is applied to each qubit from an array if the
    /// corresponding bit position of a given value is 1.
    ///
    /// # Input
    /// ## shift
    /// A nonnegative number.
    /// ## qubits
    /// An array of qubits.
    operation ApplyShift(shift : Int, qubits : Qubit[]) : Unit is Adj {
        let n = Length(qubits);
        let bits = IntAsBoolArray(shift, n);
        ApplyPauliFromBitString(PauliX, true, bits, qubits);
    }

    internal operation LittleEndianWrapper(op : (LittleEndian => Unit is Adj + Ctl), qubits : Qubit[]) : Unit is Adj + Ctl {
        op(LittleEndian(qubits));
    }

    /// # Summary
    /// Hidden-shift algorithm in which the bent function is the inner product
    /// and a permutation being applied to one operand of the inner product.
    ///
    /// # Input
    /// ## perm
    /// A permutation of 2^𝑛 elements starting from 0.
    /// ## shift
    /// The hidden shift.
    ///
    /// # Output
    /// The shift computed by the quantum circuit.
    ///
    /// # References
    /// - [*Martin Roetteler*,
    ///    Proc. SODA 2010, ACM, pp. 448-457,
    ///    2010](https://doi.org/10.1137/1.9781611973075.37)
    operation FindHiddenShift (perm : Int[], shift : Int) : Int {

        let n = BitSizeI(Length(perm) - 1);
        using (qubits = Qubit[2 * n]) {
            within {
                ApplyToEachA(H, qubits);
                ApplyShift(shift, qubits);
                ApplyPermutationUsingTransformation(perm, LittleEndian(qubits[n...]));
            } apply {
                ComputeInnerProduct(qubits);
            }

            within {
                Adjoint ApplyPermutationUsingTransformation(perm, LittleEndian(qubits[...n - 1]));
            } apply {
                ComputeInnerProduct(qubits);
            }

            ApplyToEachA(H, qubits);

            return MeasureInteger(LittleEndian(qubits));
        }
    }

}

