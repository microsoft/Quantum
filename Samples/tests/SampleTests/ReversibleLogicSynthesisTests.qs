// Author: Mathias Soeken, EPFL (Mail: mathias.soeken@epfl.ch)
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Samples.ReversibleLogicSynthesis;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;


    operation IsBitSetTest () : Unit {
        AssertBoolEqual(IsBitSet(10, 0), false, "0th bit should not be set in 10");
        AssertBoolEqual(IsBitSet(10, 1), true, "1st bit should be set in 10");
        AssertBoolEqual(IsBitSet(10, 2), false, "2nd bit should not be set in 10");
        AssertBoolEqual(IsBitSet(10, 3), true, "3rd bit should be set in 10");
        AssertBoolEqual(IsBitSet(10, 4), false, "4th bit should not be set in 10");
    }
    
    
    operation SequenceTest () : Unit {
        
        let b = 37;
        let e = 73;
        let s = Sequence(b, e);
        
        for (i in 0 .. e - b) {
            AssertIntEqual(s[i], b + i, $"Unexpected value in range at index {i}");
        }
    }
    
    
    operation NumbersTest () : Unit {
        
        let numbers = Numbers(23);
        AssertIntEqual(Length(numbers), 23, "Unexpected length of numbers array");
        
        for (i in 0 .. 22) {
            AssertIntEqual(numbers[i], i, $"Wrong number at index ${i}");
        }
    }
    
    
    operation IntegerBitsTest () : Unit {
        
        let bits = IntegerBits(10, 4);
        AssertIntEqual(Length(bits), 2, "Wrong number of bits in number 10");
        AssertIntEqual(bits[0], 1, "1st bit should be at position 1");
        AssertIntEqual(bits[1], 3, "2nd bit should be at position 3");
    }
    
    
    operation SimulatePermutation (perm : Int[]) : Bool {
        
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
    
    
    operation TBSTest () : Unit {
        
        AssertBoolEqual(SimulatePermutation([0, 1, 3, 5, 7, 2, 4, 6]), true, "Simulation with TBS failed");
        AssertBoolEqual(SimulatePermutation([0, 1, 2, 3, 4, 5, 6, 7]), true, "Simulation with TBS failed");
        AssertBoolEqual(SimulatePermutation([7, 6, 5, 4, 3, 2, 1, 0]), true, "Simulation with TBS failed");
        AssertBoolEqual(SimulatePermutation([0, 3, 2, 1]), true, "Simulation with TBS failed");
        AssertBoolEqual(SimulatePermutation([0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15]), true, "Simulation with TBS failed");
    }
    
}


