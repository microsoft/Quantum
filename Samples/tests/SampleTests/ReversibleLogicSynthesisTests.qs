// Author: Mathias Soeken, EPFL (Mail: mathias.soeken@epfl.ch)
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Samples.ReversibleLogicSynthesis;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;


    operation IsBitSetTest () : Unit {
        Fact(not IsBitSet(10, 0), "0th bit should not be set in 10");
        Fact(IsBitSet(10, 1), "1st bit should be set in 10");
        Fact(not IsBitSet(10, 2), "2nd bit should not be set in 10");
        Fact(IsBitSet(10, 3), "3rd bit should be set in 10");
        Fact(not IsBitSet(10, 4), "4th bit should not be set in 10");
    }


    operation IntegerBitsTest () : Unit {

        let bits = IntegerBits(10, 4);
        EqualityFactI(Length(bits), 2, "Wrong number of bits in number 10");
        EqualityFactI(bits[0], 1, "1st bit should be at position 1");
        EqualityFactI(bits[1], 3, "2nd bit should be at position 3");
    }


    operation SimulatePermutation (perm : Int[]) : Bool {
        mutable result = true;
        let nbits = BitSizeI(Length(perm));

        for (i in IndexRange(perm)) {

            using (qubits = Qubit[nbits]) {
                let init = IntAsBoolArray(i, nbits);
                ApplyPauliFromBitString(PauliX, true, init, qubits);
                ApplyPermutationOracle(perm, TBS, qubits);
                let simres = MeasureInteger(LittleEndian(qubits));

                if (simres != perm[i]) {
                    set result = false;
                }
            }
        }

        return result;
    }

    operation TBSTest () : Unit {
        Fact(SimulatePermutation([0, 1, 3, 5, 7, 2, 4, 6]), "Simulation with TBS failed");
        Fact(SimulatePermutation([0, 1, 2, 3, 4, 5, 6, 7]), "Simulation with TBS failed");
        Fact(SimulatePermutation([7, 6, 5, 4, 3, 2, 1, 0]), "Simulation with TBS failed");
        Fact(SimulatePermutation([0, 3, 2, 1]), "Simulation with TBS failed");
        Fact(SimulatePermutation([0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15]), "Simulation with TBS failed");
    }

}


