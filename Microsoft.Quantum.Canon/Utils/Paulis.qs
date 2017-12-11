// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;

    /// # Summary
    /// Measures the given Pauli operator using an explicit scratch
    /// qubit to perform the measurement.
    ///
    /// # Input
    /// ## pauli
    /// A multi-qubit Pauli operator specified as an array of
    /// single-qubit Pauli operators.
    /// ## target
    /// Qubit register to be measured.
    ///
    /// # Output
    /// The result of measuring the given Pauli operator on
    /// the `target` register.
    operation MeasureWithScratch(pauli : Pauli[], target : Qubit[])  : Result
    {
        body {
            mutable result = Zero;

            using (scratchRegister = Qubit[1]) {
                let scratch = scratchRegister[0];
                H(scratch);
                for (idxPauli in 0..(Length(pauli) - 1)) {
                    let P = pauli[idxPauli];
                    let src = target[idxPauli];

                    if (P == PauliX) {
                        (Controlled X)([scratch], src);
                    } elif (P == PauliY) {
                        (Controlled Y)([scratch], src);
                    } elif (P == PauliZ) {
                        (Controlled Z)([scratch], src);
                    }
                }
                H(scratch);
                set result = M(scratch);

                ResetAll(scratchRegister);
            }

            return result;
        }
    }

    /// # Summary
    /// Returns one of the single-qubit Pauli operators uniformly
    /// at random.
    ///
    /// # Output
    /// A `Pauli` operator that is one of `[PauliI; PauliX; PauliY; PauliZ]`.
    ///
    /// # Remarks
    /// This function calls <xref:microsoft.quantum.primitive.random>, so
    /// its randomess depends on the implementation of `Random`.
    operation RandomSingleQubitPauli() : Pauli {
        body {
            let probs = [0.5; 0.5; 0.5; 0.5];
            let idxPauli = Random(probs);
            let singleQubitPaulis = [PauliI; PauliX; PauliY; PauliZ];
            return singleQubitPaulis[idxPauli];
        }
    }

    /// # Summary
    /// Given a multi-qubit Pauli operator, applies the corresponding operation to
    /// a register.
    ///
    /// # Input
    /// ## pauli
    /// A multi-qubit Pauli operator represented as an array of single-qubit Pauli operators.
    /// ## target
    /// Register to apply the given Pauli operation on.
    ///
    /// # Example
    /// The following are equivalent:
    /// ```Q#
    /// ApplyPauli([PauliY; PauliZ; PauliX], target);
    ///
    /// Y(target[0]);
    /// Z(target[1]);
    /// X(target[2]);
    /// ```
    operation ApplyPauli(pauli : Pauli[], target : Qubit[])  : ()
    {
        body {
            for (idxPauli in 0..(Length(pauli) - 1)) {
                let P = pauli[idxPauli];
                let targ = target[idxPauli];

                if (P == PauliX) {
                    X(targ);
                }
                elif (P == PauliY) {
                    Y(targ);
                }
                elif (P == PauliZ) {
                    Z(targ);
                }
            }
        }

        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    /// # Summary
    /// Given a bit string, returns a multi-qubit Pauli operator
    /// represented as an array of single-qubit Pauli operators.
    ///
    /// # Input
    /// ## pauli
    /// Pauli operator to apply to qubits where `bitsApply == bits[idx]`.
    /// ## bitApply
    /// apply Pauli if bit is this value.
    /// ## bits
    /// Boolean array.
    /// ## qubits
    /// Quantum register to which a Pauli operator is to be applied.
    ///
    /// # Remarks
    /// The Boolean array and the quantum register must be of equal length.
    function PauliFromBitString(pauli : Pauli, bitApply: Bool, bits : Bool[]) : Pauli[] {
        let nBits = Length(bits);
        mutable paulis = new Pauli[nBits];

        for (idxBit in 0..nBits - 1) {
            if (bits[idxBit] == bitApply) {
                set paulis[idxBit] = pauli;
            } else {
                set paulis[idxBit] = PauliI;
            }
        }

        return paulis;
    }

    /// # Summary
    /// Applies a Pauli operator on the $n^{\text{th}}$ qubit if the $n^{\text{th}}$
    /// bit of a Boolean array matches a given input.
    ///
    /// # Input
    /// ## pauli
    /// Pauli operator to apply to `qubits[idx]` where `bitsApply == bits[idx]`
    /// ## bitApply
    /// apply Pauli if bit is this value
    /// ## bits
    /// Boolean register specifying which corresponding qubit in `qubits` should be operated on
    /// ## qubits
    /// Quantum register on which to selectively apply the specified Pauli operator
    ///
    /// # Remarks
    /// The Boolean array and the quantum register must be of equal length
    ///
    operation ApplyPauliFromBitString(pauli : Pauli, bitApply: Bool, bits : Bool[], qubits : Qubit[]) : ()
    {
        body {
            let nBits = Length(bits);
            //FailOn (nbits != Length(qubits), "Number of control bits must be equal to number of control qubits")

            for (idxBit in 0..nBits - 1) {
                if (bits[idxBit] == bitApply) {
                    ApplyPauli([pauli], [qubits[idxBit]]);
                }
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    /// # Summary
    /// Given an array of multi-qubit Pauli operators, measures each using a specified measurement
    /// gadget, then returns the array of results.
    ///
    /// # Input
    /// ## paulis
    /// Array of multi-qubit Pauli operators to measure.
    /// ## target
    /// Register on which to measure the given operators.
    /// ## gadget
    /// Operation which performs the measurement of a given multi-qubit operator.
    ///
    /// # Output
    /// The array of results obtained from measuring each element of `paulis`
    /// on `target`.
    operation MeasurePaulis(paulis : Pauli[][], target : Qubit[], gadget : ((Pauli[], Qubit[]) => Result))  : Result[]
    {
        body {
            mutable results = new Result[Length(paulis)];

            for (idxPauli in 0..(Length(paulis) - 1)) {
                set results[idxPauli] = gadget(paulis[idxPauli], target);
            }

            return results;
        }
    }

    /// # Summary
    /// Given a single-qubit Pauli operator and the index of a qubit,
    /// returns a multi-qubit Pauli operator with the given single-qubit
    /// operator at that index and `PauliI` at every other index.
    ///
    /// # Input
    /// ## pauli
    /// A single-qubit Pauli operator to be placed at the given location.
    /// ## location
    /// An index such that `output[location] == pauli`, where `output` is
    /// the output of this function.
    /// ## n
    /// Length of the array to be returned.
    ///
    /// # Example
    /// To obtain the array `[PauliI; PauliI; PauliX; PauliI]`:
    /// ```qsharp
    /// EmbedPauli(PauliX, 2, 3);
    /// ```
    function EmbedPauli(pauli : Pauli, location : Int, n : Int)  : Pauli[]
    {
        mutable pauliArray = new Pauli[n];
        for (index in 0..(n-1)) {
            if (index == location) {
                set pauliArray[index] = pauli;
            }
            else {
                set pauliArray[index] = PauliI;
            }
        }
        return pauliArray;
    }

    // FIXME: Remove in favor of something that computes arbitrary
    //        weight Paulis.
    /// # Summary
    /// Returns an array of all weight-1 Pauli operators
    /// on a given number of qubits.
    ///
    /// # Input
    /// ## nQubits
    /// The number of qubits on which the returned Pauli operators
    /// are defined.
    ///
    /// # Output
    /// An array of multi-qubit Pauli operators, each of which is
    /// represented as an array with length `nQubits`.
    function WeightOnePaulis(nQubits : Int) : Pauli[][] {
        mutable paulis = new (Pauli[])[3 * nQubits];
        let pauliGroup = [PauliX; PauliY; PauliZ];

        for (idxQubit in 0..nQubits - 1) {
            for (idxPauli in 0..Length(pauliGroup) - 1) {
                set paulis[idxQubit * Length(pauliGroup) + idxPauli] = EmbedPauli(pauliGroup[idxPauli], idxQubit, nQubits);
            }
        }

        return paulis;
    }

    // NB: This operation is intended to be private to Paulis.qs.
    operation _BasisChangeZtoY(target : Qubit) : () {
        body {
            H(target);
            S(target);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Measures each qubit in a given array in the standard basis.
    /// # Input
    /// ## targets
    /// An array of qubits to be measured.
    /// # Output
    /// An array of measurement results.
    operation MultiM(targets : Qubit[]) : Result[]
    {
        body{
            mutable results = new Result[Length(targets)];
            for(idxQubit in 0..Length(targets)-1){
                set results[idxQubit] = M(targets[idxQubit]);
            }
            return results;
        }
    }

    /// # Summary
    /// Measures a single qubit in the $Z$ basis, 
    /// and resets it to the standard basis state
    /// $\ket{0}$ following the measurement.
    ///
    /// # Input
    /// ## target
    /// A single qubit to be measured.
    ///
    /// # Output
    /// The result of measuring `target` in the Pauli $Z$ basis.
    operation MResetZ(target : Qubit) : Result {
        body {
            let result = M(target);
            if (result == One) {
                // Recall that the +1 eigenspace of a measurement operator corresponds to
                // the Result case Zero. Thus, if we see a One case, we must reset the state 
                // have +1 eigenvalue.
                X(target);
            }
            return result;
        }
    }

    /// # Summary
    /// Measures a single qubit in the $X$ basis, 
    /// and resets it to the standard basis state
    /// $\ket{0}$ following the measurement.
    ///
    /// # Input
    /// ## target
    /// A single qubit to be measured.
    ///
    /// # Output
    /// The result of measuring `target` in the Pauli $X$ basis.
    operation MResetX(target : Qubit) : Result {
        body {
            let result = Measure([PauliX], [target]);
            // We must return the qubit to the Z basis as well.
            H(target);
            if (result == One) {
                // Recall that the +1 eigenspace of a measurement operator corresponds to
                // the Result case Zero. Thus, if we see a One case, we must reset the state 
                // have +1 eigenvalue.
                X(target);
            }
            return result;
        }
    }

    /// # Summary
    /// Measures a single qubit in the $Y$ basis, 
    /// and resets it to the standard basis state
    /// $\ket{0}$ following the measurement.
    ///
    /// # Input
    /// ## target
    /// A single qubit to be measured.
    ///
    /// # Output
    /// The result of measuring `target` in the Pauli $Y$ basis.
    operation MResetY(target : Qubit) : Result {
        body {
            let result = Measure([PauliY], [target]);
            // We must return the qubit to the Z basis as well.

            (Adjoint _BasisChangeZtoY)(target);
            if (result == One) {
                // Recall that the +1 eigenspace of a measurement operator corresponds to
                // the Result case Zero. Thus, if we see a One case, we must reset the state 
                // have +1 eigenvalue.
                X(target);
            }
            return result;
        }
    }

    /// # Summary
    /// Given a single qubit, measures it and ensures it is in the $\ket{0}$ state
    /// such that it can be safely released.
    ///
    /// # Input
    /// ## target
    /// A qubit whose state is to be reset to $\ket{0}$.
    operation Reset(target : Qubit) : () {
        body {
            Ignore(MResetZ(target));
        }
    }

    /// # Summary
    /// Given an array of qubits, measure them and ensure they are in the $\ket{0}$ state
    /// such that they can be safely released.
    ///
    /// # Input
    /// ## target
    /// An array of qubits whose states are to be reset to $\ket{0}$.
    operation ResetAll(target : Qubit[]) : ()
    {
        body {
            ApplyToEach(Reset, target);
        }
    }

    operation HY(target : Qubit) : () {
        body {
            H(target);
            S(target);
        }

        adjoint auto
        controlled auto
        controlled adjoint auto
    }

}
