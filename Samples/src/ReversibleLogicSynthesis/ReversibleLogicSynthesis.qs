// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.ReversibleLogicSynthesis {
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    
    
    ////////////////////////////////////////////////////////////
    // Transformation-based synthesis                         //
    ////////////////////////////////////////////////////////////
    
    /// # Summary
    /// A type to represent a multiple-controlled multiple-target Toffoli gate.
    ///
    /// The first integer is a bit mask for control lines.  Bit indexes which
    /// are set correspond to control line indexes.
    ///
    /// The second integer is a bit mask for target lines.  Bit indexes which
    /// are set correspond to target line indexes.
    ///
    /// The bit indexes of both integers must be disjoint.
    newtype MCMTMask = (Int, Int);
    
    /// # Summary
    /// A type to represent a multiple-controlled Toffoli gate.
    ///
    /// The first value is an array of qubits for the control lines, the second
    /// value is a qubit for the target line.
    ///
    /// The target cannot be contained in the control lines.
    ///
    /// # Example
    /// ```Q#
    /// using (qubits = Qubit[4]) {
    ///   let not_gate = MCTGate(new Qubit[0], qubits[0]);
    ///   let cnot_gate = MCTGate([qubits[0]], qubits[1]);
    ///   let toffoli_gate = MCTGate([qubits[0], qubits[1]], qubits[2]);
    ///   let gate = MCTGate([qubits[0], qubits[1], qubits[2]], qubits[3]);
    /// }
    /// ```
    newtype MCTGate = (Qubit[], Qubit);
    
    
    // Some helper functions
    
    /// # Summary
    /// Checks whether bit at position is set in nonnegative number.
    ///
    /// # Input
    /// ## value
    /// A nonnegative number.
    /// ## position
    /// A bit position starting from 0.
    ///
    /// # Output
    /// Returns true, if in the binary expansion of `value` the bit at position
    /// `position` is 1, otherwise false.
    ///
    /// # Example
    /// ```Q#
    /// IsBitSet(23, 0); // true, since 23 is 10111 in binary
    /// IsBitSet(23, 3); // false
    /// ```
    ///
    /// # Note
    /// Implementation with right-shift did not work
    function IsBitSet (value : Int, position : Int) : Bool {
        
        return (value &&& 2 ^ position) == 2 ^ position;
    }
    
    
    /// # Summary
    /// Get an array of integers in a given interval.
    ///
    /// # Input
    /// ## from
    /// An inclusive nonnegative start index of the interval.
    /// ## to
    /// An inclusive nonnegative end index of the interval that is not smaller
    /// than `from`.
    ///
    /// # Output
    /// An array containing the sequence of numbers `from`, `from + 1`, ...,
    /// `to`.
    ///
    /// # Example
    /// ```Q#
    /// Sequence(0, 3); // [0, 1, 2, 3]
    /// Sequence(23, 29); // [23, 24, 25, 26, 27, 28, 29]
    /// ```
    function Sequence (from : Int, to : Int) : Int[] {
        
        let n = (to - from) + 1;
        mutable array = new Int[n];
        
        for (i in 0 .. n - 1) {
            set array[i] = from + i;
        }
        
        return array;
    }
    
    
    /// # Summary
    /// Get a sequence of numbers starting from 0.
    ///
    /// # Input
    /// ## count
    /// A nonnegative number of how many elements the resulting array should
    /// contain.
    ///
    /// # Output
    /// An array with the elements `0`, `1`, ..., `count - 1`.
    ///
    /// # Example
    /// ```Q#
    /// Numbers(3); // [0, 1, 2]
    /// Numbers(5); // [0, 1, 2, 3, 4]
    /// ```
    function Numbers (count : Int) : Int[] {
        
        mutable array = new Int[count];
        
        for (i in 0 .. count - 1) {
            set array[i] = i;
        }
        
        return array;
    }
    
    
    /// # Summary
    /// Returns all positions in which bits of an integer are set.
    ///
    /// # Input
    /// ## value
    /// A nonnegative number.
    /// ## length
    /// The number of bits in the binary expansion of `value`.
    ///
    /// # Output
    /// An array containing all bit positions (starting from 0) that are 1 in
    /// the binary expansion of `value` considering all bits up to position
    /// `length - 1`.  All positions are ordered in the array by position in an
    /// increasing order.
    ///
    /// # Example
    /// ```Q#
    /// IntegerBits(23, 5); // [0, 1, 2, 4]
    /// IntegerBits(10, 4); // [1, 3]
    /// ```
    function IntegerBits (value : Int, length : Int) : Int[] {
        
        return Filter(IsBitSet(value, _), Numbers(length));
    }
    
    
    /// # Summary
    /// Constructs a MCMTMask type as a singleton array if targets is not 0,
    /// otherwise returns an empty array.
    function GateMask (controls : Int, targets : Int) : MCMTMask[] {
        
        if (targets != 0) {
            return [MCMTMask(controls, targets)];
        }
        else {
            return new MCMTMask[0];
        }
    }
    
    
    /// # Summary
    /// Computes up to two MCMT masks to transform y to x.
    function GateMasksForAssignment (x : Int, y : Int) : MCMTMask[] {
        
        let m01 = x &&& ~~~y;
        let m10 = y &&& ~~~x;
        return GateMask(y, m01) + GateMask(x, m10);
    }
    
    
    /// # Summary
    /// Update an output pattern according to gate mask.
    function UpdateOutputPattern (pattern : Int, gateMask : MCMTMask) : Int {
        
        let (controls, targets) = gateMask!;
        
        if ((pattern &&& controls) == controls) {
            return pattern ^^^ targets;
        }
        else {
            return pattern;
        }
    }
    
    
    /// # Summary
    /// Update permutation based according to gate mask.
    function UpdatePermutation (perm : Int[], gateMask : MCMTMask) : Int[] {
        
        return Map(UpdateOutputPattern(_, gateMask), perm);
    }
    
    
    /// # Summary
    /// Computes gate masks to transform perm[x] to x and updates the current
    /// permutation.
    function TBSStep (state : (Int[], MCMTMask[]), x : Int) : (Int[], MCMTMask[]) {
        
        let (perm, gates) = state;
        let y = perm[x];
        let masks = GateMasksForAssignment(x, y);
        let new_perm = Fold(UpdatePermutation, perm, masks);
        return (new_perm, gates + masks);
    }
    
    
    /// # Summary
    /// Compute gate masks to synthesize permutation.
    function TBSMain (perm : Int[]) : MCMTMask[] {
        
        let xs = Numbers(Length(perm));
        let gates = new MCMTMask[0];
        return Reverse(Snd(Fold(TBSStep, (perm, gates), xs)));
    }
    
    
    /// # Summary
    /// Translate MCT masks into multiple-controlled Toffoli gates (with single
    /// targets).
    function GateMasksToToffoliGates (qubits : Qubit[], masks : MCMTMask[]) : MCTGate[] {
        
        mutable result = new MCTGate[0];
        let n = Length(qubits);
        
        for (i in 0 .. Length(masks) - 1) {
            let (controls, targets) = (masks[i])!;
            let controlBits = IntegerBits(controls, n);
            let targetBits = IntegerBits(targets, n);
            let cQubits = Subarray(controlBits, qubits);
            let tQubits = Subarray(targetBits, qubits);
            
            for (t in 0 .. Length(tQubits) - 1) {
                set result = result + [MCTGate(cQubits, tQubits[t])];
            }
        }
        
        return result;
    }
    
    
    /// # Summary
    /// Transformation-based synthesis algorithm.
    ///
    /// This procedure implements the unidirectional transformation based
    /// synthesis approach.  Input is a permutation π over 2^𝑛 elements {0, ...,
    /// 2^𝑛-1}, which represents an 𝑛-variable reversible Boolean function.  The
    /// algorithm performs iteratively the following steps:
    ///
    /// 1. Find smallest 𝑥 such that 𝑥 ≠ π(𝑥) = 𝑦
    /// 2. Find multiple-controlled Toffoli gates, which applied to the outputs
    ///    make π(𝑥) = 𝑥 and do not change π(𝑥') for all 𝑥' < 𝑥
    ///
    /// # Input
    /// ## perm
    /// A permutation of 2^𝑛 elements starting from 0.
    /// ## qubits
    /// A list of 𝑛 qubits where the Toffoli gates are being applied to.  Note
    /// that the algorithm does not apply the gates.  But only prepares the
    /// Toffoli gates.  The function should be called as argument to the
    /// function `PermutationOracle`.
    ///
    /// # Output
    /// A list of multiple-controlled Toffoli gates.
    ///
    /// # Example
    /// ```Q#
    /// using (qubits = Qubit[3]) {
    ///   PermutationOracle([0, 2, 1, 3], TBS, qubits); // synthesize SWAP operation
    /// }
    /// ```
    ///
    /// # References
    /// - [*D. Michael Miller*, *Dmitri Maslov*, *Gerhard W. Dueck*,
    ///    Proc. DAC 2003, IEEE, pp. 318-323,
    ///    2003](https://doi.org/10.1145/775832.775915)
    /// - [*Mathias Soeken*, *Gerhard W. Dueck*, *D. Michael Miller*,
    ///    Proc. RC 2016, Springer, pp. 307-321,
    ///    2016](https://doi.org/10.1007/978-3-319-40578-0_22)
    function TBS (perm : Int[], qubits : Qubit[]) : MCTGate[] {
        
        let masks = TBSMain(perm);
        return GateMasksToToffoliGates(qubits, masks);
    }
    
    
    ////////////////////////////////////////////////////////////
    // Generic permutation synthesis                          //
    ////////////////////////////////////////////////////////////
    
    /// # Summary
    /// Synthesize Toffoli network from a permutation using functional
    /// synthesis.
    ///
    /// # Input
    /// ## perm
    /// A permutation of 2^𝑛 elements starting from 0.
    /// ## synth
    /// A synthesis algorithm that takes as input a permutation and returns an
    /// array of `MCTGate` gates (e.g., `TBS`).
    /// ## qubits
    /// A list of 𝑛 qubits where the Toffoli gates are being applied to.  This
    /// operation will apply these gates.
    ///
    /// # Example
    /// ```Q#
    /// using (qubits = Qubit[3]) {
    ///   PermutationOracle([0, 2, 1, 3], TBS, qubits); // synthesize SWAP operation
    /// }
    /// ```
    operation PermutationOracle (perm : Int[], synth : ((Int[], Qubit[]) -> MCTGate[]), qubits : Qubit[]) : Unit {
        
        body (...) {
            let gates = synth(perm, qubits);
            
            for (i in 0 .. Length(gates) - 1) {
                let (controls, target) = (gates[i])!;
                Controlled X(controls, target);
            }
        }
        
        adjoint invert;
        controlled auto;
        controlled adjoint auto;
    }
    
    
    ////////////////////////////////////////////////////////////
    // Example program to synthesize a permutation            //
    ////////////////////////////////////////////////////////////
    
    /// # Summary
    /// Takes as input a permutation, finds a quantum circuit using
    /// transformation-based synthesis, and checks whether the circuit realizes
    /// the input permutation.
    ///
    /// # Input
    /// ## perm
    /// A permutation of 2^𝑛 elements starting from 0.
    ///
    /// # Output
    /// True, if the circuit correctly implements the permutation.
    operation PermutationSimulation (perm : Int[]) : Bool {
        
        mutable result = true;
        let nbits = BitSize(Length(perm));
        
        for (i in 0 .. Length(perm) - 1) {
            
            using (qubits = Qubit[nbits]) {
                let init = BoolArrFromPositiveInt(i, nbits);
                ApplyPauliFromBitString(PauliX, true, init, qubits);
                PermutationOracle(perm, TBS, qubits);
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
    operation InnerProduct (qubits : Qubit[]) : Unit {
        
        let n = Length(qubits) / 2;
        
        for (i in 0 .. n - 1) {
            Controlled Z([qubits[i]], qubits[n + i]);
        }
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
    operation ApplyShift (shift : Int, qubits : Qubit[]) : Unit {
        
        body (...) {
            let n = Length(qubits);
            let bits = BoolArrFromPositiveInt(shift, n);
            ApplyPauliFromBitString(PauliX, true, bits, qubits);
        }
        
        adjoint invert;
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
    operation HiddenShiftProblem (perm : Int[], shift : Int) : Int {
        
        let n = BitSize(Length(perm));
        mutable result = 0;
        
        using (qubits = Qubit[2 * n]) {
            let Superpos = ApplyToEachA(H, _);
            let Shift = ApplyShift(shift, _);
            let Synth = PermutationOracle(perm, TBS, _);
            let PermX = ApplyToSubregisterA(Synth, Sequence(0, n - 1), _);
            let PermY = ApplyToSubregisterA(Synth, Sequence(n, 2 * n - 1), _);
            With(BindA([Superpos, Shift, PermY]), InnerProduct, qubits);
            With(Adjoint PermX, InnerProduct, qubits);
            Superpos(qubits);
            set result = MeasureInteger(LittleEndian(qubits));
        }
        
        return result;
    }
    
}


