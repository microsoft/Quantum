// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

namespace Microsoft.Quantum.Samples.ColoringGroverWithConstraints {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;

    /// # Summary
    /// Read color from a register.
    ///
    /// # Input
    /// ## register
    /// The register of qubits to be measured.
    operation MeasureColor (register : Qubit[]) : Int {
        return MeasureInteger(LittleEndian(register));
    }

    /// # Summary
    /// Read coloring from a register.
    ///
    /// # Input
    /// ## bitsPerColor
    /// Number of bits per color.
    /// ## register
    /// The register of qubits to be measured.
    operation MeasureColoring (bitsPerColor : Int, register : Qubit[]) : Int[] {
        let numVertices = Length(register) / bitsPerColor;
        let colorPartitions = Partitioned(ConstantArray(numVertices - 1, bitsPerColor), register);
        return ForEach(MeasureColor, colorPartitions);
    } 

    /// # Summary
    /// N-bit color equality oracle (no extra qubits.)
    ///
    /// # Input
    /// ## color0
    /// First color.
    /// ## color1
    /// Second color.
    ///
    /// # Output
    /// Target will be 1 if colors are the same.
    operation ApplyColorEqualityOracle (color0 : Qubit[], color1 : Qubit[], 
        target : Qubit) : Unit is Adj+Ctl {
        within {
            for ((q0, q1) in Zip(color0, color1)) {
                // compute XOR of q0 and q1 in place (storing it in q1).
                CNOT(q0, q1);
            }
        } apply {
            // if all XORs are 0, the bit strings are equal.
            (ControlledOnInt(0, X))(color1, target);
        }
    }

    /// # Summary
    /// Oracle for verifying vertex coloring, including color constraints from
    /// non qubit vertices.
    ///
    /// # Input
    /// ## numVertices
    /// The number of vertices in the graph.
    /// ## bitsPerColor
    /// The bits per color e.g. 2 bits per color allows for 4 colors.
    /// ## edges
    /// The array of (Vertex#,Vertex#) specifying the Vertices that can not be
    /// the same color.
    /// ## startingColorConstraints
    /// The array of (Vertex#,Color) specifying the dissallowed colors for vertices.
    ///
    /// # Output
    /// A unitary operation that applies `oracle` on the target register if the control 
    /// register state corresponds to the bit mask `bits`.
    ///
    /// # Example
    /// Consider the following 4x4 Sudoku puzzle
    /// ``` 
    ///     -----------------
    ///     |   |   | 2 | 3 |
    ///     -----------------
    ///     |   |   | 0 | 1 |
    ///     -----------------
    ///     | 1 | 2 | 3 | 0 |
    ///     -----------------
    ///     | 3 | 0 | 1 | 2 |
    ///     -----------------
    /// ```
    ///  The challenge is to fill the empty squares with numbers 0 to 3
    ///  that are unique in row, column and the top left 2x2 square.
    ///  This is a graph coloring problem where the colors are 0 to 3
    ///  and the empty cells are the vertices. The vertices can be defined as:
    /// ```
    ///     -----------------
    ///     | 0 | 1 |   |   |
    ///     -----------------
    ///     | 2 | 3 |   |   |
    ///     -----------------
    ///     |   |   |   |   |
    ///     -----------------
    ///     |   |   |   |   |
    ///     -----------------
    /// ```
    /// The graph is
    /// ```
    ///  0---1
    ///  | X |
    ///  1---2
    /// ```
    /// i.e. every vertex is connected to each other.
    /// Additionally, we require that:
    ///
    ///    - vertices 0 and 1 do not get colors 2 and 3.
    ///    - vertices 2 and 3 do not get colors 3 and 0.
    ///    - vertices 0 and 2 do not get colors 1 and 3.
    ///    - vertices 1 and 3 do not get colors 2 and 0.
    /// This results in edges (vertices that can not be same color):
    /// `edges = [(1, 0),(2, 0),(3, 0),(3, 1),(3, 2)]`
    /// This is saying that vertex 1 can not have same color as vertex 0 etc.
    /// and startingColorConstraints = [(0, 1),(0, 3),(0, 2),(1, 2),(1, 0),
    ///                    (1, 3),(2, 1),(2, 3),(2, 0),(3, 2),(3, 0),(3, 1)]
    /// This is saying that vertex 0 is not allowed to have values 1,3,2
    /// and vertex 1 is not allowed to have values 2,0,3
    /// and vertex 2 is not allowed to have values 1,3,0
    /// and vertex 3 is not allowed to have values 2,0,1
    /// A valid graph coloring solution is: [0,1,2,3]
    /// i.e. vextex 0 has color 0, vertex 1 has color 1 etc.
    operation ApplyVertexColoringOracle (numVertices : Int, bitsPerColor : Int, edges : (Int, Int)[],  
        startingColorConstraints : (Int, Int)[], 
        colorsRegister : Qubit[], 
        target : Qubit) : Unit is Adj+Ctl {
        let nEdges = Length(edges);
        let nStartingColorConstraints = Length(startingColorConstraints);
        // we are looking for a solution that:
        // (a) has no edge with same color at both ends and 
        // (b) has no Vertex with a color that violates the starting color constraints.
        using ((edgeConflictQubits, startingColorConflictQubits) = (Qubit[nEdges], Qubit[nStartingColorConstraints])) {
            within {
                ConstrainByEdgeAndStartingColors(colorsRegister, edges, startingColorConstraints, 
                    edgeConflictQubits, startingColorConflictQubits, bitsPerColor);
            } apply {
                // If there are no conflicts (all qubits are in 0 state), the vertex coloring is valid.
                (ControlledOnInt(0, X))(edgeConflictQubits + startingColorConflictQubits, target);
            }
        }
    }

    operation ConstrainByEdgeAndStartingColors (colorsRegister : Qubit[], edges : (Int, Int)[], startingColorConstraints : (Int, Int)[],
        edgeConflictQubits : Qubit[], startingColorConflictQubits : Qubit[], bitsPerColor: Int): Unit is Adj+Ctl {
        for (((start, end), conflictQubit) in Zip(edges, edgeConflictQubits)) {
            // Check that endpoints of the edge have different colors:
            // apply ColorEqualityOracle_Nbit oracle; 
            // if the colors are the same the result will be 1, indicating a conflict
            ApplyColorEqualityOracle(
                colorsRegister[start * bitsPerColor .. (start + 1) * bitsPerColor - 1], 
                colorsRegister[end * bitsPerColor .. (end + 1) * bitsPerColor - 1], conflictQubit);
        }
        for (((cell, value), conflictQubit) in 
            Zip(startingColorConstraints, startingColorConflictQubits)) {
            // Check that cell does not clash with starting colors.
            (ControlledOnInt(value, X))(colorsRegister[
                cell * bitsPerColor .. (cell + 1) * bitsPerColor - 1], conflictQubit);
        }

    }

    /// # Summary
    /// Oracle for verifying vertex coloring, including color constraints 
    /// from non qubit vertices. This is the same as ApplyVertexColoringOracle, 
    /// but hardcoded to 4 bits per color and restriction that colors are 
    /// limited to 0 to 8.
    ///
    /// # Input
    /// ## numVertices
    /// The number of vertices in the graph.
    /// ## edges
    /// The array of (Vertex#,Vertex#) specifying the Vertices that can not 
    /// be the same color.
    /// ## startingColorConstraints
    /// The array of (Vertex#,Color) specifying the dissallowed colors for vertices.
    /// ## colorsRegister
    /// The color register.
    /// ## target
    /// The target of the operation.
    ///
    /// # Output
    /// A unitary operation that applies `oracle` on the target register if the control 
    /// register state corresponds to the bit mask `bits`.
    ///
    /// # Example
    /// Consider the following 9x9 Sudoku puzzle:
    /// ```
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
    /// ```
    ///  The challenge is to fill the empty squares with numbers 0 to 8
    ///  that are unique in row, column and the top left 3x3 square
    ///  This is a graph coloring problem where the colors are 0 to 8
    ///  and the empty cells are the vertices. The vertices can be defined as
    /// ```  
    ///     -----------------
    ///     | 0 |   |   |   | ...
    ///     -----------------
    ///     |   | 1 |   |   | ...
    ///     -----------------
    ///     |   |   |   |   | ...
    ///     ...
    /// ```
    /// The graph is
    /// ```
    ///     0---1 
    /// ```
    /// Additionally, we also require that 
    ///    - vertex 0 can not have value 6,2,7,8,3,4,0,1 (row constraint)
    ///                         or value 8,7,6,4,0,3,1,2 (col constraint)
    ///    - vertex 1 can not value 8,1,6,2,4,3,7,5 (row constraint)
    ///                    or value 6,3,8,1,2,5,7,4 (col constraint)
    /// This results in edges (vertices that can not be same color)
    /// edges = [(1, 0)]
    /// This is saying that vertex 1 can not have same color as vertex 0
    /// and startingColorConstraints = [(0, 8),(0, 7),(0, 6),(0, 4),(0, 0),(0, 3),
    ///     (0, 1),(0, 2),(1, 6),(1, 3),(1, 8),(1, 1),(1, 2),(1, 5),(1, 7),(1, 4)]
    /// The colors found must be from 0 to 8, which requires 4 bits per color.
    /// A valid graph coloring solution is: [5,0]
    /// i.e. vextex 0 has color 5, vertex 1 has color 0.
    operation ApplyVertexColoringOracle4Bit9Color (numVertices : Int, edges : (Int, Int)[],  
        startingColorConstraints : (Int, Int)[], 
        colorsRegister : Qubit[], target : Qubit) : Unit is Adj+Ctl {
        let nEdges = Length(edges);
        let bitsPerColor = 4; // 4 bits per color
        let nStartingColorConstraints = Length(startingColorConstraints);
        // we are looking for a solution that:
        // (a) has no edge with same color at both ends and 
        // (b) has no Vertex with a color that violates the starting color constraints.
        using ((edgeConflictQubits, startingColorConflictQubits, vertexColorConflictQubits) = 
          (Qubit[nEdges], Qubit[nStartingColorConstraints], Qubit[numVertices])) {
            within {
                ConstrainByEdgeAndStartingColors(colorsRegister, edges, startingColorConstraints, 
                    edgeConflictQubits, startingColorConflictQubits, bitsPerColor);
                let zippedColorAndConfictQubit = Zip(
                    Partitioned(ConstantArray(numVertices, bitsPerColor), colorsRegister),
                    vertexColorConflictQubits);
                for ((color, conflictQubit) in zippedColorAndConfictQubit) {
                    // Only allow colors from 0 to 8 i.e. if bit #3 = 1, then bits 2..0 must be 000.
                    using (tempQubit = Qubit()) {
                        within {
                            ApplyOrOracle(color[0 .. 2], tempQubit);
                        } apply{
                            // AND color's most significant bit with OR of least significant bits. 
                            // This will set conflictQubit to 1 if color > 8.
                            CCNOT(color[3], tempQubit, conflictQubit);
                        }
                    }
                }
            } apply {
                // If there are no conflicts (all qubits are in 0 state), the vertex coloring is valid.
                (ControlledOnInt(0, X))(edgeConflictQubits + startingColorConflictQubits + vertexColorConflictQubits, target);
            }
        }
    }

    /// # Summary
    /// OR oracle for an arbitrary number of qubits in query register.
    ///
    /// # Inputs
    /// ## queryRegister
    /// Qubit register to query.
    /// ## target
    /// Target qubit for storing oracle result.
    operation ApplyOrOracle (queryRegister : Qubit[], target : Qubit) : Unit is Adj {        
        // x₀ ∨ x₁ = ¬ (¬x₀ ∧ ¬x₁)
        // First, flip target if both qubits are in |0⟩ state.
        (ControlledOnInt(0, X))(queryRegister, target);
        // Then flip target again to get negation.
        X(target);
    }
    
    /// # Summary
    /// Using Grover's search to find vertex coloring.
    ///
    /// # Input
    /// ## numVertices
    /// The number of Vertices in the graph.
    /// ## bitsPerColor
    /// The number of bits per color.
    /// ## maxIterations
    /// An estimate of the maximum iterations needed.
    /// ## oracle
    /// The Oracle used to find solution.
    /// 
    /// # Output
    /// Int Array giving the color of each vertex.
    ///
    /// # Remarks
    /// See https://github.com/microsoft/QuantumKatas/tree/main/SolveSATWithGrover
    /// for original implementation in SolveSATWithGrover Kata.
    operation FindColorsWithGrover (numVertices : Int, bitsPerColor : Int, maxIterations : Int, 
        oracle : ((Qubit[], Qubit) => Unit is Adj)) : Int[] {
        // This task is similar to task 2.2 from SolveSATWithGrover kata, 
        // but the percentage of correct solutions is potentially higher.
        mutable coloring = new Int[numVertices];

        // Note that coloring register has the number of qubits that is 
        // twice the number of vertices (bitsPerColor qubits per vertex).
        using ((register, output) = (Qubit[bitsPerColor * numVertices], Qubit())) {
            mutable correct = false;
            mutable iter = 1;
            // Try for one iteration, if it fails, try again for one more iteration and repeat until maxIterations is reached.
            repeat {
                Message($"Trying search with {iter} iterations...");
                ApplyGroversAlgorithmLoop(register, oracle, iter);
                let res = MultiM(register);
                // to check whether the result is correct, apply the oracle to the 
                // register plus auxiliary after measurement.
                oracle(register, output);
                if (MResetZ(output) == One) {
                    set correct = true;
                    // Read off coloring.
                    set coloring = MeasureColoring(bitsPerColor, register);
                }
                ResetAll(register);
            } until (correct or iter > maxIterations)  
            fixup {
                set iter += 1;
            }
            if (not correct) {
                fail "Failed to find a coloring.";
            }
        }
        return coloring;
    }

    /// # Summary
    /// Grover algorithm loop
    ///
    /// # Input
    /// ## oracle
    /// The oracle which will mark the valid solutions.
    ///
    /// # Remarks
    /// See https://github.com/microsoft/QuantumKatas/tree/main/SolveSATWithGrover
    /// for the original implementation from the SolveSATWithGrover kata.
        operation ApplyPhaseOracle (oracle : ((Qubit[], Qubit) => Unit is Adj), 
        register : Qubit[]) : Unit is Adj {

        using (target = Qubit()) {
            within {
                // Put the target into the |-⟩ state.
                X(target);
                H(target);
            } apply {
                // Apply the marking oracle; since the target is in the |-⟩ state,
                // flipping the target if the register satisfies the oracle condition 
                // will apply a -1 factor to the state.
                oracle(register, target);
            }
            // We put the target back into |0⟩ so we can return it.
        }
    }
    
    /// # Summary
    /// Grover's Algorithm loop.
    ///
    /// # Input
    /// ## register
    /// The register of qubits.
    /// ## oracle
    /// The oracle defining the solution we want.
    /// ## iterations
    /// The number of iterations to try.
    ///
    /// # Output
    /// Unitary implementing Grover's search algorithm.
    operation ApplyGroversAlgorithmLoop (register : Qubit[], 
        oracle : ((Qubit[], Qubit) => Unit is Adj), iterations : Int) : Unit {
        let applyPhaseOracle = ApplyPhaseOracle(oracle, _);
        ApplyToEach(H, register);
            
        for (_ in 1 .. iterations) {
            applyPhaseOracle(register);
            within {
                ApplyToEachA(H, register);
                ApplyToEachA(X, register);
            } apply {
                Controlled Z(Most(register), Tail(register));
            }
        }
    }
}
