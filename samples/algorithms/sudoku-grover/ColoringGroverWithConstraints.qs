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
        let nVertices = Length(register) / bitsPerColor;
        let colorPartitions = Partitioned([bitsPerColor, size=(nVertices - 1)], register);
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
    /// ## target
    /// Will be flipped if colors are the same.
    operation ApplyColorEqualityOracle(
        color0 : Qubit[], color1 : Qubit[],
        target : Qubit
    )
    : Unit is Adj + Ctl {
        within {
            // compute XOR of q0 and q1 in place (storing it in q1).
            ApplyToEachCA(CNOT, Zipped(color0, color1));
        } apply {
            // if all XORs are 0, the bit strings are equal.
            ControlledOnInt(0, X)(color1, target);
        }
    }

    /// # Summary
    /// Oracle for verifying vertex coloring
    ///
    /// # Input
    /// ## nVertices
    /// The number of vertices in the graph.
    /// ## bitsPerColor
    /// The bits per color e.g. 2 bits per color allows for 4 colors.
    /// ## edges
    /// The array of (Vertex#,Vertex#) specifying the Vertices that can not be
    /// the same color.
    ///
    /// # Output
    /// An marking oracle that marks as allowed those states in which the colors of qubits related by an edge constraint are not equal.
    ///
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
    operation ApplyVertexColoringOracle (
        nVertices : Int, 
        bitsPerColor : Int, 
        edges : (Int, Int)[],
        colorsRegister : Qubit[],
        target : Qubit
    )
    : Unit is Adj + Ctl {
        let nEdges = Length(edges);
        // we are looking for a solution that has no edge with same color at both ends
        use edgeConflictQubits = Qubit[nEdges];
        within {
            for ((start, end), conflictQubit) in Zipped(edges, edgeConflictQubits) {
                // Check that endpoints of the edge have different colors:
                // apply ApplyColorEqualityOracle oracle;
                // if the colors are the same the result will be 1, indicating a conflict
                ApplyColorEqualityOracle(
                    colorsRegister[start * bitsPerColor .. (start + 1) * bitsPerColor - 1],
                    colorsRegister[end * bitsPerColor .. (end + 1) * bitsPerColor - 1],
                    conflictQubit
                );
            }
        } apply {
            // If there are no conflicts (all qubits are in 0 state), the vertex coloring is valid.
            ControlledOnInt(0, X)(edgeConflictQubits, target);
        }
    }

    /// # Summary
    /// Using Grover's search to find vertex coloring.
    ///
    /// # Input
    /// ## nVertices
    /// The number of Vertices in the graph.
    /// ## bitsPerColor
    /// The number of bits per color.
    /// ## nIterations
    /// The number of iterations needed.
    /// ## oracle
    /// The Oracle used to find solution.
    /// ## statePrep
    /// An operation that prepares an equal superposition of all basis states in the search space.
    ///
    /// # Output
    /// An array giving the color of each vertex.
    operation FindColorsWithGrover(
        nVertices : Int, 
        bitsPerColor : Int, 
        nIterations : Int,
        oracle : ((Qubit[], Qubit) => Unit is Adj),
        statePrep : (Qubit[] => Unit is Adj)) : Int[] {

        // Coloring register has bitsPerColor qubits for each vertex
        use register = Qubit[bitsPerColor * nVertices];

        Message($"Trying search with {nIterations} iterations...");
        if (nIterations > 75) {
            Message($"Warning: This might take a while");
        }
        ApplyGroversAlgorithmLoop(register, oracle, statePrep, nIterations);
        return MeasureColoring(bitsPerColor, register);
    }

    /// # Summary
    /// Converts a marking oracle into a phase oracle.
    ///
    /// # Input
    /// ## oracle
    /// The oracle which will mark the valid solutions.
    ///
    /// # Output
    /// A phase oracle that flips the phase of a state, iff the marking oracle marks the state.
    operation ApplyPhaseOracle (oracle : ((Qubit[], Qubit) => Unit is Adj),
        register : Qubit[]
    )
    : Unit is Adj {
        use target = Qubit();
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
    /// # Remarks
    /// Unitary implementing Grover's search algorithm.
    operation ApplyGroversAlgorithmLoop(
        register : Qubit[],
        oracle : ((Qubit[], Qubit) => Unit is Adj),
        statePrep : (Qubit[] => Unit is Adj),
        iterations : Int
    )
    : Unit {
        let applyPhaseOracle = ApplyPhaseOracle(oracle, _);
        statePrep(register);

        for _ in 1 .. iterations {
            applyPhaseOracle(register);
            within {
                Adjoint statePrep(register);
                ApplyToEachA(X, register);
            } apply {
                Controlled Z(Most(register), Tail(register));
            }
        }
    }
}
