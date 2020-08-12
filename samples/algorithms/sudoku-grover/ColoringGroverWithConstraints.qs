// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Microsoft.Quantum.Samples.ColoringGroverWithConstraints {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;

    // Read color from a register
    operation MeasureColor (register : Qubit[]) : Int {
        return ResultArrayAsInt(MultiM(register));
    }

    // Read coloring from a register
    operation MeasureColoring (K : Int, register : Qubit[]) : Int[] {
        let V = Length(register) / K;
        let colorPartitions = Partitioned(ConstantArray(V-1, K), register);
        return ForEach(MeasureColor, colorPartitions);
    } 

    // N-bit color equality oracle (no extra qubits)
    operation ColorEqualityOracle_Nbit (c0 : Qubit[], c1 : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        within {
            for ((q0, q1) in Zip(c0, c1)) {
                // compute XOR of q0 and q1 in place (storing it in q1)
                CNOT(q0, q1);
            }
        } apply {
            // if all XORs are 0, the bit strings are equal
            (ControlledOnInt(0, X))(c1, target);
        }
    }

    // Oracle for verifying vertex coloring, including color constraints from non QuBit vertexes
    operation VertexColoringOracle (V : Int, K: Int, edges : (Int, Int)[],  startingColorConstraints : (Int, Int)[], colorsRegister : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        let nEdges = Length(edges);
        let nStartingColorConstraints = Length(startingColorConstraints);
        // we are looking for a solution that (a) has no edge with same color at both ends and (b) has no Vertex with a color that violates the starting color constraints
        using (conflictQubits = Qubit[nEdges+nStartingColorConstraints]) {
            within {
                for (((start, end), conflictQubit) in Zip(edges, conflictQubits[0 .. nEdges-1])) {
                    // Check that endpoints of the edge have different colors:
                    // apply ColorEqualityOracle_Nbit oracle; if the colors are the same the result will be 1, indicating a conflict
                    ColorEqualityOracle_Nbit(colorsRegister[start * K .. (start + 1) * K - 1], 
                                                       colorsRegister[end * K .. (end + 1) * K - 1], conflictQubit);
                }
                for (((cell, value), conflictQubit) in Zip(startingColorConstraints, conflictQubits[nEdges .. nEdges + nStartingColorConstraints - 1])) {
                    // Check that cell does not clash with starting colors
                    (ControlledOnInt(value, X))(colorsRegister[cell * K .. (cell + 1) * K - 1], conflictQubit);
                }
            } apply {
                // If there are no conflicts (all qubits are in 0 state), the vertex coloring is valid
                (ControlledOnInt(0, X))(conflictQubits, target);
            }
        }
    }

    // Oracle for verifying vertex coloring, including color constraints from non QuBit vertexes
    // same as VertexColoringOracle, but hardcoded to 4 bits per color and restriction that colors are limited to 0 to 8.
    operation VertexColoringOracle4Bit9Color (V : Int, edges : (Int, Int)[],  startingColorConstraints : (Int, Int)[], colorsRegister : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        let nEdges = Length(edges);
        let K = 4; // 4 bits per color
        let nStartingColorConstraints = Length(startingColorConstraints);
        // we are looking for a solution that (a) has no edge with same color at both ends and (b) has no Vertex with a color that violates the starting color constraints
        using (conflictQubits = Qubit[nEdges+nStartingColorConstraints+V]) {
            within {
                for (((start, end), conflictQubit) in Zip(edges, conflictQubits[0 .. nEdges-1])) {
                    // Check that endpoints of the edge have different colors:
                    // apply ColorEqualityOracle_Nbit oracle; if the colors are the same the result will be 1, indicating a conflict
                    ColorEqualityOracle_Nbit(colorsRegister[start * K .. (start + 1) * K - 1], 
                                                       colorsRegister[end * K .. (end + 1) * K - 1], conflictQubit);
                }
                for (((cell, value), conflictQubit) in Zip(startingColorConstraints, conflictQubits[nEdges .. nEdges + nStartingColorConstraints - 1])) {
                    // Check that cell does not clash with starting colors
                    (ControlledOnInt(value, X))(colorsRegister[cell * K .. (cell + 1) * K - 1], conflictQubit);
                } 
                let z = Zip(Partitioned(ConstantArray(V, K), colorsRegister),conflictQubits[nEdges + nStartingColorConstraints .. nEdges + nStartingColorConstraints + V-1]);
                for ((color,conflictQubit) in z) {
                    // Only allow colors from 0 to 8 i.e. if bit #3 = 1, then bits 2..0 must be 000.
                    using (tempQubit = Qubit()) {
                        within {
                            Oracle_Or(color[0..2], tempQubit);
                        } apply{
                            // AND color's most significant bit with OR of least significant bits. This will set conflictQubit to 1 if color > 8
                            CCNOT(color[3],tempQubit,conflictQubit);
                        }
                    }
                }
            } apply {
                // If there are no conflicts (all qubits are in 0 state), the vertex coloring is valid
                (ControlledOnInt(0, X))(conflictQubits, target);
            }
        }
    }

        // OR oracle for an arbitrary number of qubits in query register
    operation Oracle_Or (queryRegister : Qubit[], target : Qubit) : Unit is Adj {        
        // x₀ ∨ x₁ = ¬ (¬x₀ ∧ ¬x₁)
        // First, flip target if both qubits are in |0⟩ state
        (ControlledOnInt(0, X))(queryRegister, target);
        // Then flip target again to get negation
        X(target);
    }
    
    // Using Grover's search to find vertex coloring. K = #bits per color
    operation GroversAlgorithm (V : Int, K: Int, maxIterations: Int, oracle : ((Qubit[], Qubit) => Unit is Adj)) : Int[] {
        // This task is similar to task 2.2 from SolveSATWithGrover kata, but the percentage of correct solutions is potentially higher.
        mutable coloring = new Int[V];

        // Note that coloring register has the number of qubits that is twice the number of vertices (K qubits per vertex).
        using ((register, output) = (Qubit[K * V], Qubit())) {
            mutable correct = false;
            mutable iter = 1;
            repeat {
                Message($"Trying search with {iter} iterations");
                GroversAlgorithm_Loop(register, oracle, iter);
                let res = MultiM(register);
                // to check whether the result is correct, apply the oracle to the register plus ancilla after measurement
                oracle(register, output);
                if (MResetZ(output) == One) {
                    set correct = true;
                    // Read off coloring
                    set coloring = MeasureColoring(K, register);
                }
                ResetAll(register);
            } until (correct or iter > maxIterations)  // the fail-safe to avoid going into an infinite loop
            fixup {
                set iter += 1;
            }
            if (not correct) {
                fail "Failed to find a coloring";
            }
        }
        return coloring;
    }

    // Grover loop implementation taken from SolveSATWithGrover kata.
    operation OracleConverterImpl (markingOracle : ((Qubit[], Qubit) => Unit is Adj), register : Qubit[]) : Unit is Adj {

        using (target = Qubit()) {
            within {
                // Put the target into the |-⟩ state
                X(target);
                H(target);
            } apply {
                // Apply the marking oracle; since the target is in the |-⟩ state,
                // flipping the target if the register satisfies the oracle condition will apply a -1 factor to the state
                markingOracle(register, target);
            }
            // We put the target back into |0⟩ so we can return it
        }
    }
    
    operation GroversAlgorithm_Loop (register : Qubit[], oracle : ((Qubit[], Qubit) => Unit is Adj), iterations : Int) : Unit {
        let phaseOracle = OracleConverterImpl(oracle, _);
        ApplyToEach(H, register);
            
        for (_ in 1 .. iterations) {
            phaseOracle(register);
            within {
                ApplyToEachA(H, register);
                ApplyToEachA(X, register);
            } apply {
                Controlled Z(Most(register), Tail(register));
            }
        }
    }
}