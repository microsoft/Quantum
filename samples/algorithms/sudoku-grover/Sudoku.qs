// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

namespace Microsoft.Quantum.Samples.SudokuGrover {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Samples.ColoringGroverWithConstraints;

    /// # Summary
    /// Solve a Sudoku puzzle using Grover's algorithm.
    ///
    /// # Description
    /// Sudoku is a graph coloring problem where graph edges must connect nodes 
    /// of different colors.
    /// In our case, graph nodes are puzzle squares and colors are the Sudoku numbers. 
    /// Graph edges are the constraints preventing squares from having the same values. 
    /// To reduce the number of qubits needed, we only use qubits for empty squares.
    /// We define the puzzle using 2 data structures:
    ///
    ///   - A list of edges connecting empty squares
    ///   - A list of constraints on empty squares to the initial numbers 
    ///     in the puzzle (starting numbers)
    /// The code works for both 9x9 Sudoku puzzles, and 4x4 Sudoku puzzles. 
    /// This description will use a 4x4 puzzle to make it easier to understand.
    /// The 4x4 puzzle is solved with number 0 to 3 instead of 1 to 4. 
    /// This is because we can encode 0-3 with 2 qubits.
    /// However, the same rules apply:
    ///    - The numbers 0 to 3 may only appear once per row, column and 2x2 sub squares.
    /// As an example              has solution
    /// _________________          _________________
    /// |   | 1 |   | 3 |          | 0 | 1 | 2 | 3 |  
    /// -----------------          -----------------
    /// | 2 |   |   | 1 |          | 2 | 3 | 0 | 1 |  
    /// -----------------          -----------------
    /// |   |   | 3 | 0 |          | 1 | 2 | 3 | 0 |  
    /// -----------------          -----------------
    /// | 3 |   | 1 |   |          | 3 | 0 | 1 | 2 |  
    /// -----------------          -----------------
    ///
    /// In the above example, the edges/constraints for the top row are:
    ///   _________
    ///  | ______   \                   _____   
    ///  || __   \   \                  | __  \                        __
    /// _|||__\___\_ _\__         ______||__\___\__          _________|___\__ 
    /// |   | 1 |   | 3 |         |   | 1 |   | 3 |         |   | 1 |   | 3 | 
    /// -----------------         -----------------         -----------------
    ///
    /// For the row above, the empty squares have indexes
    /// _________________
    /// | 0 |   | 1 |   |
    /// -----------------
    /// For this row the list of emptySquareEdges has only 1 entry:
    /// emptySquareEdges = (0,1)         
    /// i.e. empty square 0 can't have the same number as empty square 1.
    /// The constraints on these empty squares to the starting numbers are:
    /// startingNumberConstraints = (0,1)  (0,3)  (1,1)  (1,3)   
    /// This is a list of (empty square #, number it can't be).  
    /// i.e. empty square 0 can't have value 1 or 3, 
    /// and empty square #1 can't have values 1 or 3.
    ///
    /// # Input
    /// ## nVertices
    /// number of blank squares.
    /// ## size
    /// The size of the puzzle. 4 for 4x4 grid, 9 for 9x9 grid.
    /// ## emptySquareEdges
    /// The traditional edges passed to the graph coloring algorithm which, 
    /// in our case, are empty puzzle squares.
    /// These edges define any "same row", "same column", "same sub-grid" 
    /// relationships between empty cells.
    /// Look at the README.md sample output to see examples of what this is 
    /// for different sample puzzles.
    /// ## startingNumberConstraints
    /// The constraints on the empty squares due to numbers already in the 
    /// puzzle when we start.
    /// Look at the README.md sample output to see examples of what this is 
    /// for different sample puzzles.
    ///
    /// # Output
    /// A tuple with Result and the array of numbers for each empty square.
    /// Look at the README.md sample output to see examples of what this is 
    /// for different sample puzzles.
    ///
    /// # Remarks
    /// The inputs and outputs for the following 4x4 puzzle are:
    ///    -----------------
    ///    |   | 1 | 2 | 3 |         <--- empty square #0
    ///    -----------------
    ///    | 2 |   | 0 | 1 |         <--- empty square #1
    ///    -----------------
    ///    | 1 | 2 | 3 | 0 |
    ///    -----------------
    ///    | 3 |   | 1 | 2 |         <--- empty square #2
    ///    -----------------
    ///    emptySquareEdges = [(1, 0),(2, 1)]    
    ///         empty square #0 can not have the same color/number as empty call #1.
    ///         empty square #1 and #2 can not have the same color/number (same column).
    ///    startingNumberConstraints = [(0, 2),(0, 1),(0, 3),(1, 1),(1, 2),(1, 0),(2, 1),(2, 2),(2, 3)]
    ///         empty square #0 can not have values 2,1,3 because same row/column/2x2grid.
    ///         empty square #1 can not have values 1,2,0 because same row/column/2x2grid.
    ///    Results = [0,3,0] i.e. Empty Square #0 = 0, Empty Square #1 = 3, Empty Square #2 = 0.
    operation SolvePuzzle(
        nVertices : Int, size : Int,
        emptySquareEdges : (Int, Int)[],
        startingNumberConstraints: (Int, Int)[]
    )
    : (Bool, Int[]) {
        if size != 4 and size != 9 {
            fail $"Cannot set size {size}: only a grid size of 4x4 or 9x9 is supported";
        }
        let bitsPerColor = size == 9 ? 4 | 2;
        let oracle = ApplyVertexColoringOracle(nVertices, bitsPerColor, emptySquareEdges, _, _);
        let statePrep = PrepareSearchStatesSuperposition(nVertices, bitsPerColor, startingNumberConstraints, _);
        let searchSpaceSize = SearchSpaceSize(nVertices, bitsPerColor, startingNumberConstraints);
        let numIterations = NIterations(searchSpaceSize);
        Message($"Running Quantum test with # of vertices = {nVertices}");
        Message($"   Bits Per Color = {bitsPerColor}");
        Message($"   emptySquareEdges = {emptySquareEdges}");
        Message($"   startingNumberConstraints = {startingNumberConstraints}");
        Message($"   Estimated #iterations needed = {numIterations}");
        Message($"   Size of Sudoku grid = {size}x{size}");
        Message($"   Search space size = {searchSpaceSize}");
        let coloring = FindColorsWithGrover(nVertices, bitsPerColor, numIterations, oracle, statePrep);

        Message($"Got Sudoku solution: {coloring}");
        if (IsSudokuSolutionValid(size, emptySquareEdges, startingNumberConstraints, coloring)) {
           Message($"Got valid Sudoku solution: {coloring}");
           return (true, coloring);
        } else {
           Message($"Got invalid Sudoku solution: {coloring}");
           return (false, coloring);
        }
    }


    /// # Summary
    /// Encodes stating number constraints into amplitudes.
    ///
    /// # Inputs
    /// ## nVertices
    /// The number of vertices in the graph.
    /// ## bitsPerColor
    /// The bit width for number of colors.
    /// ## startingNumberConstraints
    /// The array of (Vertex#, Color) specifying the disallowed colors for vertices.
    ///
    /// # Examples
    /// Consider the case where we have 2 vertices, 2 bits per color, and the constraints (0,1),(0,2),(0,3),(1,2).
    /// Then we would get the result where all non-disallowed values have a 1.0 amplitude:
    /// [[1.0, 0.0, 0.0, 0.0], 
    ///  [1.0, 1.0, 0.0, 1.0]]
    ///
    ///
    /// # Output
    /// A 2D array of amplitudes where the first index is the cell and the second index is the value of a basis state (i.e., value) for the cell. =
    /// Allowed amplitudes will have a value 1.0, disallowed amplitudes 0.0
    function AllowedAmplitudes(
        nVertices : Int,
        bitsPerColor : Int,
        startingNumberConstraints : (Int, Int)[]
    ) : Double[][] {
        mutable amplitudes = [[1.0, size=1 <<< bitsPerColor], size=nVertices];
        for (cell, value) in startingNumberConstraints {
            set amplitudes w/= cell <- (amplitudes[cell] w/ value <- 0.0);
        }
        return amplitudes;
    }


    /// # Summary
    /// Prepare an equal superposition of all basis states that satisfy the constraints
    /// imposed by the digits already placed in the grid.
    ///
    /// # Inputs
    /// ## nVertices
    /// The number of vertices in the graph.
    /// ## bitsPerColor
    /// The bit width for number of colors.
    /// ## startingNumberConstraints
    /// The array of (Vertex#, Color) specifying the disallowed colors for vertices.
    ///
    /// # Remarks
    /// Prepares the search space. Using the allowed amplitudes prepares uniform superposition of all allowed values for each cell
    operation PrepareSearchStatesSuperposition(
        nVertices : Int,
        bitsPerColor : Int,
        startingNumberConstraints : (Int, Int)[],
        register : Qubit[]
    ) : Unit is Adj + Ctl {
        // Split the given register into nVertices chunks of size bitsPerColor.
        let colorRegisters = Chunks(bitsPerColor, register);
        // For each vertex, create an array of possible states we're looking at.
        let amplitudes = AllowedAmplitudes(nVertices, bitsPerColor, startingNumberConstraints);
        // For each vertex, prepare a superposition of its possible states on the chunk storing its color.
        for (amps, chunk) in Zipped(amplitudes, colorRegisters) {
            PrepareArbitraryStateD(amps, LittleEndian(chunk));
        }
    }

    /// # Summary
    /// Show the size of the search space, i.e. the number of possible combinations
    ///
    /// # Inputs
    /// ## nVertices
    /// The number of vertices in the graph.
    /// ## bitsPerColor
    /// The bit width for number of colors.
    /// ## startingNumberConstraints
    /// The array of (Vertex#, Color) specifying the disallowed colors for vertices.
    ///
    /// # Output
    /// The size of the search space (i.e., number of possible combinations)
    function SearchSpaceSize(
        nVertices : Int,
        bitsPerColor : Int,
        startingNumberConstraints : (Int, Int)[]
    ) : Int {
        mutable colorOptions = [1 <<< bitsPerColor, size=nVertices];
        for (cell, _) in startingNumberConstraints {
            set colorOptions w/= cell <- colorOptions[cell] - 1;
        }
        return Fold(TimesI, 1, colorOptions);
    }

    /// # Summary
    /// Estimate the number of iterations required for solution.
    ///
    /// # Input
    /// ## searchSpaceSize
    /// The size of the search space.
    ///
    /// # Remarks
    /// This is correct for an amplitude amplification problem with a single 
    /// correct solution, but would need to be adapted when there are multiple
    /// solutions
    function NIterations(searchSpaceSize : Int) : Int {
        let angle = ArcSin(1. / Sqrt(IntAsDouble(searchSpaceSize)));
        let nIterations = Round(0.25 * PI() / angle - 0.5);
        return nIterations;
    }

    /// # Summary
    /// Check if the colors/numbers found for each empty square are in the correct 
    /// range (e.g. <9 for a 9x9 puzzle) and satisfy all edge/starting number constraints.
    /// 
    /// # Input
    /// ## size
    /// The size of the puzzle. 4 for 4x4 grid, 9 for 9x9 grid.
    /// ## edges
    /// The traditional edges passed to the graph coloring algorithm which, 
    /// in our case, are empty puzzle squares.
    /// These edges define any "same row", "same column", "same sub-grid" 
    /// relationships between empty cells.
    /// Look at the README.md sample output to see examples of what this is 
    /// for different sample puzzles.
    /// ## startingNumberConstraints
    /// The constraints on the empty squares due to numbers already in the 
    /// puzzle when we start. Look at the README.md sample output to see 
    /// examples of what this is for different sample puzzles.
    /// ## colors
    /// An Int array of numbers for each empty square i.e. the puzzle solution.
    /// 
    /// # Output
    /// A boolean value of true if the colors found satisfy all the solution requirements.
    function IsSudokuSolutionValid (
        size : Int,
        edges : (Int, Int)[],
        startingNumberConstraints : (Int, Int)[],
        colors : Int[]
    )
    : Bool {
        if (Any(GreaterThanOrEqualI(_, size), colors)) { return false; }
        if (Any(EqualI, edges)) { return false; }
        for (index, startingNumber) in startingNumberConstraints {
            if (colors[index] == startingNumber) {
                return false;
            }
        }
        return true;
    }

}
