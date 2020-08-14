namespace Microsoft.Quantum.Samples.SudokuGrover {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Samples.ColoringGroverWithConstraints;

    /// # Summary
    /// Solve a Sudoku puzzle using Grover's algorithm
    ///
    ///
    /// # Description
    /// Sudoku is a graph coloring problem where graph edges must connect nodes of different colors
    /// In our case, Graph Nodes are puzzle squares and colors are the Sudoku numbers. 
    /// Graph Edges are the constraints preventing squares from having the same values. 
    /// To reduce the number of QuBits needed, we only use QuBits for empty squares
    /// We define the puzzle using 2 data structures.
    ///   - A list of edges connecting empty squares
    ///   - A list of constraints on empty squares to the initial numbers in the puzzle (starting numbers)
    /// The code works for both 9x9 Sudoku puzzles, and 4x4 Sudoku puzzles. 
    /// This description will use a 4x4 puzzle to make it easier to understand
    /// The 4x4 puzzle is solved with number 0 to 3 instead of 1 to 4. 
    /// This is because we can encode 0-3 with 2 Qubits.
    /// However, the same rules apply
    ///    - The numbers 0 to 3 may only appear once per row, column and 2x2 sub squares
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
    /// In the above example, the edges/constraints for the top row are
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
    /// For this row the list of emptySquareEdges has only 1 entry
    /// emptySquareEdges = (0,1)         
    /// i.e. empty square 0 can't have the same number as empty square 1
    /// The constraints on these empty squares to the starting numbers are
    /// startingNumberConstraints = (0,1)  (0,3)  (1,1)  (1,3)   
    /// This is a list of (empty square #, number it can't be)  
    /// i.e. empty square 0 can't have value 1 or 3, and empty square #1 can't have values 1 or 3
    ///
    ///
    /// # Input
    /// ## V
    /// number of blank squares
    /// ## size
    /// The size of the puzzle. 4 for 4x4 grid, 9 for 9x9 grid
    /// ## emptySquareEdges
    /// The traditional edges passed to the graph coloring algorithm which, in our case, are empty puzzle squares.
    /// These edges define any "same row", "same column", "same sub-grid" relationships between empty cells
    /// Look at the README.md sample output to see examples of what this is for different sample puzzles
    /// ## startingNumberConstraints
    /// The constraints on the empty squares due to numbers already in the puzzle when we start.
    /// Look at the README.md sample output to see examples of what this is for different sample puzzles
    ///
    /// # Output
    /// A Tuple with Result and the array of numbers for each empty square
    /// Look at the README.md sample output to see examples of what this is for different sample puzzles
    ///
    /// # Remarks
    /// The inputs and outputs for the following 4x4 puzzle are
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
    ///         empty square #0 can not have the same color/number as empty call #1 because they are diagonal
    ///         empty square #1 and #2 can not have the same color/number because they are in the same column
    ///    startingNumberConstraints = [(0, 2),(0, 1),(0, 3),(1, 1),(1, 2),(1, 0),(2, 1),(2, 2),(2, 3)]
    ///         empty square #0 can not have values 2,1,3 because those are in the same row/column/2x2grid
    ///         empty square #1 can not have values 1,2,0 because those are in the same row/column/2x2grid
    ///    Results = [0,3,0] i.e. Empty Square #0 = 0, Empty Square #1 = 3, Empty Square #2 = 0
    operation SolvePuzzle(V : Int, size: Int, emptySquareEdges: (Int, Int)[], startingNumberConstraints: (Int, Int)[]) : (Bool, Int[]) {
        mutable bitsPerColor = 2; // if size == 4x4 grid
        if (size == 9)
        {
            set bitsPerColor = 4; // if size == 9x9 grid
        }
        let numIterations = NIterations(bitsPerColor * V);
        Message($"Running Quantum test with #Vertex = {V}");
        Message($"   Bits Per Color = {bitsPerColor}");
        Message($"   emptySquareEdges = {emptySquareEdges}");
        Message($"   startingNumberConstraints = {startingNumberConstraints}");
        Message($"   estimated #iterations needed = {numIterations}");
        Message($"   size of Sudoku grid = {size}x{size}");
        mutable coloring = new Int[0];
        if (size == 4) {
            set coloring = GroversAlgorithm(V, 2, numIterations*2, VertexColoringOracle(V, 2, emptySquareEdges, startingNumberConstraints, _, _));
        }
        elif (size == 9) {
            set coloring = GroversAlgorithm(V, 4, numIterations*2, VertexColoringOracle4Bit9Color(V, emptySquareEdges, startingNumberConstraints, _, _));
        }

        Message($"Got sudoku solution: {coloring}");
        if (IsSudokuSolutionValid(V, size, emptySquareEdges, startingNumberConstraints, coloring)) {
           Message($"Got valid sudoku solution: {coloring}");
           return (true, coloring);
        } else {
           Message($"Got invalid sudoku solution: {coloring}");
           return (false, coloring);
        }
    }

    /// # Summary
    /// Estimate the number of interations required for solution
    function NIterations(nQubits : Int) : Int {
        let nItems = 1 <<< nQubits; // 2^numQubits
        // compute number of iterations:
        let angle = ArcSin(1. / Sqrt(IntAsDouble(nItems)));
        let nIterations = Round(0.25 * PI() / angle - 0.5);
        return nIterations;
    }

    /// # Summary
    /// Check if the colors/numbers found for each empty square are in the correct range (e.g. <9 for a 9x9 puzzle) 
    /// and satisfy all edge/starting number constraints
    function IsSudokuSolutionValid (V : Int, size: Int, edges: (Int, Int)[], startingNumberConstraints: (Int, Int)[], colors: Int[]) : Bool {
        for (color in colors) {
            if (color >= size) {
                return false;
            }
        }
        for ((start, end) in edges) {
            if (colors[start] == colors[end]) {
                return false;
            }
        }
        for ((index, startingNumber) in startingNumberConstraints) {
            if (colors[index] == startingNumber) {
                return false;
            }
        }
        return true;
    }

}
