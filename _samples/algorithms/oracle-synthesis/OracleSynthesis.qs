// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.OracleSynthesis {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;

    /// # Summary
    /// Computes Hadamard transform of a Boolean function in {-1,1} encoding
    /// using Yates's method
    ///
    /// # Input
    /// ## func
    /// Truth table in {-1,1} encoding
    ///
    /// # Output
    /// Spectral coefficients of the function
    ///
    /// # Example
    /// ```Q#
    /// FastHadamardTransform([1, 1, 1, -1]); // [2, 2, 2, -2]
    /// ```
    ///
    /// # Reference
    /// Frank Yates: The design and analysis of factorial experiments, in:
    /// Technical Communication No. 35, Imperial Bureau of Soil Science,
    /// London (1937)
    function FastHadamardTransform(func : Int[]) : Int[] {
        let bits = BitSizeI(Length(func) - 1);
        mutable res = func;
        for (m in 0..bits - 1) {
            mutable s = 1 <<< m;
            for (i in 0..(2 * s)..Length(func) - 1) {
                mutable k = i + s;
                for (j in i..i + s - 1) {
                    mutable t = res[j];
                    set res w/= j <- res[j] + res[k];
                    set res w/= k <- t - res[k];
                    set k = k + 1;
                }
            }
        }
        return res;
    }

    /// # Summary
    /// Converts integer for truth table into array of Booleans
    ///
    /// # Input
    /// ## func
    /// Truth table in integer representation
    /// ## vars
    /// Number of variables in truth table
    ///
    /// # Output
    /// Array of 2^vars truth table values
    function TruthTable(func : Int, vars : Int) : Bool[] {
        return IntAsBoolArray(func, 1 <<< vars);
    }

    /// # Summary
    /// Extends a spectrum by inverted coefficients
    ///
    /// # Input
    /// ## spectrum
    /// Spectral coefficients
    ///
    /// # Output
    /// Coefficients followed by inverted copy
    ///
    /// # Example
    /// ```Q#
    /// Extend([2, 2, 2, -2]); // [2, 2, 2, -2, -2, -2, -2, 2]
    /// ```
    function Extend(spectrum : Int[]) : Int[] {
        return spectrum + Mapped(NegationI, spectrum);
    }

    /// # Summary
    /// {-1,1} coding of a Boolean truth value
    ///
    /// # Input
    /// ## b
    /// Boolean value
    ///
    /// # Output
    /// 1, if `b` is false, otherwise -1
    function RMEncoding(b : Bool) : Int {
        return b ? -1 | 1;
    }

    /// # Summary
    /// Encode truth table in {1,-1} coding
    ///
    /// # Input
    /// ## table
    /// Truth table as array of truth values
    ///
    /// # Output
    /// Truth table as array of {1,-1} integers
    ///
    /// # Example
    /// ```Q#
    /// Encode([false, false, false, true]); // [1, 1, 1, -1]
    /// ```
    function Encode(table : Bool[]) : Int[] {
        return Mapped(RMEncoding, table);
    }

    /// # Summary
    /// Creates Gray code sequences
    ///
    /// # Input
    /// ## n
    /// Number of bits
    ///
    /// # Output
    /// Array of tuples. First value in tuple is value in GrayCode sequence
    /// Second value in tuple is position to change in current value to get
    /// next one.
    ///
    /// # Example
    /// ```Q#
    /// GrayCode(2); // [(0, 0);(1, 1);(3, 0);(2, 1)]
    /// ```
    function GrayCode(n : Int) : (Int, Int)[] {
        let N = 1 <<< n;

        mutable res = new (Int, Int)[N];
        mutable j = 0;
        mutable current = IntAsBoolArray(0, n);

        for (i in 0..N - 1) {
            if (i % 2 == 0) {
                set j = 0;
            } else {
                let e = Zip(current, RangeAsIntArray(0..N - 1));
                set j = Snd(Head(Filtered(Fst<Bool, Int>, e))) + 1;
            }

            set j = MaxI(0, Min([j, n - 1]));
            set res w/= i <- (BoolArrayAsInt(current), j);
            if (j < n) {
                set current w/= j <- not current[j];
            }
        }

        return res;
    }

    /// # Summary
    /// Implements oracle circuit for function
    ///
    /// # Input
    /// ## func
    /// Oracle function in truth table representation
    /// ## controls
    /// Control qubits
    /// ## target
    /// Target qubit
    operation ApplyOracleFromFunction(func : Bool[], controls : Qubit[], target : Qubit) : Unit {
        let vars = Length(controls);
        let table = Encode(func);
        let spectrum = Extend(FastHadamardTransform(table));

        let qubits = controls + [target];

        HY(target);

        for (i in 0..vars) {
            let start = 1 <<< i;
            let code = GrayCode(i);
            for (j in 0..Length(code) - 1) {
                let (offset, ctrl) = code[j];
                RFrac(PauliZ, -spectrum[start + offset], vars + 2, qubits[i]);
                if (i != 0) {
                    CNOT(qubits[ctrl], qubits[i]);
                }
            }
        }

        H(target);
    }

    /// # Summary
    /// Implements oracle circuit for a given function, assuming that target qubit
    /// is initialized 0.  The adjoint operation assumes that the target
    /// qubit will be released to 0.
    ///
    /// # Input
    /// ## func
    /// Oracle function in truth table representation
    /// ## controls
    /// Control qubits
    /// ## target
    /// Target qubit
    operation ApplyOracleFromFunctionOnCleanTarget(func : Bool[], controls : Qubit[], target : Qubit) : Unit {
        body (...) {
            let vars = Length(controls);
            let table = Encode(func);
            let spectrum = FastHadamardTransform(table);

            AssertAllZero([target]);

            HY(target);

            let code = GrayCode(vars);
            for (j in 0..Length(code) - 1) {
                let (offset, ctrl) = code[j];
                RFrac(PauliZ, spectrum[offset], vars + 2, target);
                CNOT(controls[ctrl], target);
            }

            H(target);
        }
        adjoint (...) {
            let vars = Length(controls);
            let table = Encode(func);
            let spectrum = FastHadamardTransform(table);

            H(target);
            AssertProb([PauliZ], [target], One, 0.5, "Probability of the measurement must be 0.5", 1e-10);
            if (IsResultOne(M(target))) {
                for (i in 0..vars - 1) {
                    let start = 1 <<< i;
                    let code = GrayCode(i);
                    for (j in 0..Length(code) - 1) {
                        let (offset, ctrl) = code[j];
                        RFrac(PauliZ, -spectrum[start + offset], vars + 1, controls[i]);
                        if (i != 0) {
                            CNOT(controls[ctrl], controls[i]);
                        }
                    }
                }
                Reset(target);
            }
        }
    }

    /// # Summary
    /// Operation to run Oracle operation
    operation RunOracleSynthesis(func : Int, vars : Int) : Bool {
        mutable result = true;
        let tableBits = TruthTable(func, vars);

        for (x in 0..(1 <<< (vars + 1)) - 1) {
            using (qubits = Qubit[vars + 1]) {
                let init = IntAsBoolArray(x, vars + 1);
                ApplyPauliFromBitString(PauliX, true, init, qubits);
                ApplyOracleFromFunction(tableBits, qubits[0..vars - 1], qubits[vars]);

                let y = IsResultOne(M(qubits[vars])) != init[vars];
                if ((tableBits + tableBits)[x] != y) {
                    set result = false;
                }
                ResetAll(qubits);
            }
        }

        return result;
    }

    /// # Summary
    /// Operation to run OracleCleanTargetQubit operation
    operation RunOracleSynthesisOnCleanTarget(func : Int, vars : Int) : Bool {
        mutable result = true;
        let tableBits = TruthTable(func, vars);

        for (x in 0..Length(tableBits) - 1) {
            using (qubits = Qubit[vars + 2]) {
                let init = IntAsBoolArray(x, vars);
                ApplyPauliFromBitString(PauliX, true, init, qubits[0..vars - 1]);
                ApplyOracleFromFunctionOnCleanTarget(tableBits, qubits[0..vars - 1], qubits[vars]);
                CNOT(qubits[vars], qubits[vars + 1]);
                (Adjoint ApplyOracleFromFunctionOnCleanTarget)(tableBits, qubits[0..vars - 1], qubits[vars]);

                let y = IsResultOne(M(qubits[vars + 1]));
                if (tableBits[x] != y) {
                    set result = false;
                }
                if (y) {
                    Reset(qubits[vars + 1]);
                }
                ApplyPauliFromBitString(PauliX, true, init, qubits[0..vars - 1]);
            }
        }

        return result;
    }
}
