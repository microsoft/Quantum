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

    /// # Summary
    /// Read color from a register
    operation MeasureColor (register : Qubit[]) : Int {
        return ResultArrayAsInt(MultiM(register));
    }

    /// # Summary
    /// Read coloring from a register
    operation MeasureColoring (K : Int, register : Qubit[]) : Int[] {
        let V = Length(register) / K;
        let colorPartitions = Partitioned(ConstantArray(V-1, K), register);
        return ForEach(MeasureColor, colorPartitions);
    } 

    /// # Summary
    /// N-bit color equality oracle (no extra qubits)
    operation ColorEqualityOracle_Nbit (c0 : Qubit[], c1 : Qubit[], 
        target : Qubit) : Unit is Adj+Ctl {
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

    /// # Summary
    /// Oracle for verifying vertex coloring, including color constraints from
    /// non QuBit vertexes
    ///
    /// # Input
    /// ## V
    /// The number of vertices in the graph
    /// ## K
    /// The bits per color e.g. 2 bits per color allows for 4 colors
    /// ## edges
    /// The array of (Vertex#,Vertex#) specifying the Vertices that can not be
    /// the same color
    /// ## startingColorConstraints
    /// The array of (Vertex#,Color) specifying the dissallowed colors for vertices
    ///
    /// # Output
    /// A unitary operation that applies `oracle` on the target register if the control 
    /// register state corresponds to the bit mask `bits`.
    ///
    /// # Example
    /// Consider the following 4x4 Sudoku puzzle 
    ///     -----------------
    ///     |   |   | 2 | 3 |
    ///     -----------------
    ///     |   |   | 0 | 1 |
    ///     -----------------
    ///     | 1 | 2 | 3 | 0 |
    ///     -----------------
    ///     | 3 | 0 | 1 | 2 |
    ///     -----------------
    ///  The challenge is to fill the empty squares with numbers 0 to 3
    ///  that are unique in row, column and the top left 2x2 square
    ///  This is a graph coloring problem where the colors are 0 to 3
    ///  and the empty cells are the Vertexes. The Vertexes can be defined as   
    ///     -----------------
    ///     | 0 | 1 |   |   |
    ///     -----------------
    ///     | 2 | 3 |   |   |
    ///     -----------------
    ///     |   |   |   |   |
    ///     -----------------
    ///     |   |   |   |   |
    ///     -----------------
    /// The graph is
    ///  0---1
    ///  | X |
    ///  1---2
    /// i.e. every vertex is connected to each other
    /// But we also require that 
    ///    - vertexes 0 and 1 do not get colors 2 and 3
    ///    - vertexes 2 and 3 do not get colors 3 and 0
    ///    - vertexes 0 and 2 do not get colors 1 and 3
    ///    - vertexes 1 and 3 do not get colors 2 and 0 
    /// This results in edges (vertexes that can not be same color)
    /// edges = [(1, 0),(2, 0),(3, 0),(3, 1),(3, 2)]
    /// This is saying that vertex 1 can not have same color as vertex 0 etc.
    /// and startingColorConstraints = [(0, 1),(0, 3),(0, 2),(1, 2),(1, 0),
    ///                    (1, 3),(2, 1),(2, 3),(2, 0),(3, 2),(3, 0),(3, 1)]
    /// This is saying that vertex 0 is not allowed to have values 1,3,2
    /// and vertex 1 is not allowed to have values 2,0,3
    /// and vertex 2 is not allowed to have values 1,3,0
    /// and vertex 3 is not allowed to have values 2,0,1
    /// A valid graph coloring solution is: [0,1,2,3]
    /// i.e. vextex 0 has color 0, vertex 1 has color 1 etc.
    operation VertexColoringOracle (V : Int, K: Int, edges : (Int, Int)[],  
        startingColorConstraints : (Int, Int)[], 
        colorsRegister : Qubit[], 
        target : Qubit) : Unit is Adj+Ctl {
        let nEdges = Length(edges);
        let nStartingColorConstraints = Length(startingColorConstraints);
        // we are looking for a solution that
        // (a) has no edge with same color at both ends and 
        // (b) has no Vertex with a color that violates the starting color constraints
        using (conflictQubits = Qubit[nEdges+nStartingColorConstraints]) {
            within {
                for (((start, end), conflictQubit) in Zip(edges, conflictQubits[0 .. nEdges-1])) {
                    // Check that endpoints of the edge have different colors:
                    // apply ColorEqualityOracle_Nbit oracle; 
                    // if the colors are the same the result will be 1, indicating a conflict
                    ColorEqualityOracle_Nbit(colorsRegister[start * K .. (start + 1) * K - 1], 
                                             colorsRegister[end * K .. (end + 1) * K - 1], conflictQubit);
                }
                for (((cell, value), conflictQubit) in 
                    Zip(startingColorConstraints, conflictQubits[nEdges .. nEdges + nStartingColorConstraints - 1])) {
                    // Check that cell does not clash with starting colors
                    (ControlledOnInt(value, X))(colorsRegister[cell * K .. (cell + 1) * K - 1], conflictQubit);
                }
            } apply {
                // If there are no conflicts (all qubits are in 0 state), the vertex coloring is valid
                (ControlledOnInt(0, X))(conflictQubits, target);
            }
        }
    }

    /// # Summary
    /// Oracle for verifying vertex coloring, including color constraints 
    /// from non qubit vertexes. This is the same as VertexColoringOracle, 
    /// but hardcoded to 4 bits per color and restriction that colors are 
    /// limited to 0 to 8.
    ///
    /// # Input
    /// ## V
    /// The number of vertices in the graph
    /// ## edges
    /// The array of (Vertex#,Vertex#) specifying the Vertices that can not 
    /// be the same color
    /// ## startingColorConstraints
    /// The array of (Vertex#,Color) specifying the dissallowed colors for vertices
    /// ## colorsRegister
    /// The color register
    /// ## target
    /// The target of the operation
    ///
    /// # Output
    /// A unitary operation that applies `oracle` on the target register if the control 
    /// register state corresponds to the bit mask `bits`.
    ///
    /// # Example
    /// Consider the following 4x4 Sudoku puzzle 
    ///    -------------------------------------
    ///    |   | 6 | 2 | 7 | 8 | 3 | 4 | 0 | 1 |
    ///    -------------------------------------
    ///    | 8 |   | 1 | 6 | 2 | 4 | 3 | 7 | 5 |
    ///    -------------------------------------
    ///    | 7 | 3 | 4 | 5 | 0 | 1 | 8 | 6 | 2 |
    ///    -------------------------------------
    ///    | 6 | 8 | 7 | 1 | 5 | 0 | 2 | 4 | 3 |
    ///    -------------------------------------
    ///    | 4 | 1 | 5 | 3 | 6 | 2 | 7 | 8 | 0 |
    ///    -------------------------------------
    ///    | 0 | 2 | 3 | 4 | 7 | 8 | 1 | 5 | 6 |
    ///    -------------------------------------
    ///    | 3 | 5 | 8 | 0 | 1 | 7 | 6 | 2 | 4 |
    ///    -------------------------------------
    ///    | 1 | 7 | 6 | 2 | 4 | 5 | 0 | 3 | 8 |
    ///    -------------------------------------
    ///    | 2 | 4 | 0 | 8 | 3 | 6 | 5 | 1 | 7 |
    ///    -------------------------------------
    ///  The challenge is to fill the empty squares with numbers 0 to 8
    ///  that are unique in row, column and the top left 3x3 square
    ///  This is a graph coloring problem where the colors are 0 to 8
    ///  and the empty cells are the Vertexes. The Vertexes can be defined as   
    ///     -----------------
    ///     | 0 |   |   |   | ...
    ///     -----------------
    ///     |   | 1 |   |   | ...
    ///     -----------------
    ///     |   |   |   |   | ...
    ///     ...
    /// The graph is
    ///  0---1
    /// But we also require that 
    ///    - vertex 0 can not have value 7,3,8,9,4,5,1,2 (row constraint)
    ///                         or value 8,7,6,4,0,3,1,2 (col constraint)
    ///    - vertex 1 can not value 8,1,6,2,4,3,7,5 (row constraint)
    ///                    or value 6,3,8,1,2,5,7,4 (col constraint)
    /// This results in edges (vertexes that can not be same color)
    /// edges = [(1, 0)]
    /// This is saying that vertex 1 can not have same color as vertex 0
    /// and startingColorConstraints = [(0, 8),(0, 7),(0, 6),(0, 4),(0, 0),(0, 3),
    ///     (0, 1),(0, 2),(1, 6),(1, 3),(1, 8),(1, 1),(1, 2),(1, 5),(1, 7),(1, 4)]
    /// The colors found must be from 0 to 8, which requires 4 bits per color
    /// A valid graph coloring solution is: [5,0]
    /// i.e. vextex 0 has color 5, vertex 1 has color 0
        operation VertexColoringOracle4Bit9Color (V : Int, edges : (Int, Int)[],  
        startingColorConstraints : (Int, Int)[], 
        colorsRegister : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        let nEdges = Length(edges);
        let K = 4; // 4 bits per color
        let nStartingColorConstraints = Length(startingColorConstraints);
        // we are looking for a solution that 
        // (a) has no edge with same color at both ends and 
        // (b) has no Vertex with a color that violates the starting color constraints
        using (conflictQubits = Qubit[nEdges+nStartingColorConstraints+V]) {
            within {
                for (((start, end), conflictQubit) in Zip(edges, conflictQubits[0 .. nEdges-1])) {
                    // Check that endpoints of the edge have different colors:
                    // apply ColorEqualityOracle_Nbit oracle; 
                    // if the colors are the same the result will be 1, indicating a conflict
                    ColorEqualityOracle_Nbit(
                        colorsRegister[start * K .. (start + 1) * K - 1], 
                        colorsRegister[end * K .. (end + 1) * K - 1], conflictQubit);
                }
                for (((cell, value), conflictQubit) in 
                    Zip(startingColorConstraints, 
                        conflictQubits[nEdges .. nEdges + nStartingColorConstraints - 1])) {
                    // Check that cell does not clash with starting colors
                    (ControlledOnInt(value, X))(colorsRegister[cell * K .. (cell + 1) * K - 1], conflictQubit);
                } 
                let z = Zip(Partitioned(ConstantArray(V, K), colorsRegister),
                            conflictQubits[nEdges + nStartingColorConstraints .. nEdges + nStartingColorConstraints + V-1]);
                for ((color,conflictQubit) in z) {
                    // Only allow colors from 0 to 8 i.e. if bit #3 = 1, then bits 2..0 must be 000.
                    using (tempQubit = Qubit()) {
                        within {
                            Oracle_Or(color[0..2], tempQubit);
                        } apply{
                            // AND color's most significant bit with OR of least significant bits. 
                            // This will set conflictQubit to 1 if color > 8
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

    /// # Summary
    /// OR oracle for an arbitrary number of qubits in query register
    operation Oracle_Or (queryRegister : Qubit[], target : Qubit) : Unit is Adj {        
        // x₀ ∨ x₁ = ¬ (¬x₀ ∧ ¬x₁)
        // First, flip target if both qubits are in |0⟩ state
        (ControlledOnInt(0, X))(queryRegister, target);
        // Then flip target again to get negation
        X(target);
    }
    
    /// # Summary
    /// Using Grover's search to find vertex coloring.
    ///
    /// # Input
    /// ## V
    /// The number of Vertices in the graph
    /// ## K
    /// The number of bits per color
    /// ## maxIterations
    /// An estimate of the maximum iterations needed
    /// ## oracle
    /// The Oracle used to find solution
    operation GroversAlgorithm (V : Int, K: Int, maxIterations: Int, 
        oracle : ((Qubit[], Qubit) => Unit is Adj)) : Int[] {
        // This task is similar to task 2.2 from SolveSATWithGrover kata, 
        // but the percentage of correct solutions is potentially higher.
        mutable coloring = new Int[V];

        // Note that coloring register has the number of qubits that is 
        // twice the number of vertices (K qubits per vertex).
        using ((register, output) = (Qubit[K * V], Qubit())) {
            mutable correct = false;
            mutable iter = 1;
            repeat {
                Message($"Trying search with {iter} iterations");
                GroversAlgorithm_Loop(register, oracle, iter);
                let res = MultiM(register);
                // to check whether the result is correct, apply the oracle to the 
                // register plus ancilla after measurement
                oracle(register, output);
                if (MResetZ(output) == One) {
                    set correct = true;
                    // Read off coloring
                    set coloring = MeasureColoring(K, register);
                }
                ResetAll(register);
            } until (correct or iter > maxIterations)  
            fixup {
                set iter += 1;
            }
            if (not correct) {
                fail "Failed to find a coloring";
            }
        }
        return coloring;
    }

    /// # Summary
    /// Grover loop implementation taken from SolveSATWithGrover kata.
    operation OracleConverterImpl (markingOracle : ((Qubit[], Qubit) => Unit is Adj), 
        register : Qubit[]) : Unit is Adj {

        using (target = Qubit()) {
            within {
                // Put the target into the |-⟩ state
                X(target);
                H(target);
            } apply {
                // Apply the marking oracle; since the target is in the |-⟩ state,
                // flipping the target if the register satisfies the oracle condition 
                // will apply a -1 factor to the state
                markingOracle(register, target);
            }
            // We put the target back into |0⟩ so we can return it
        }
    }
    
    /// # Summary
    /// Grover's Algorithm loop
    operation GroversAlgorithm_Loop (register : Qubit[], 
        oracle : ((Qubit[], Qubit) => Unit is Adj), iterations : Int) : Unit {
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
