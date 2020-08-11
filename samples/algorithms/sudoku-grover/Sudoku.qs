namespace Microsoft.Quantum.Samples.SudokuGrover {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Samples.ColoringGroverWithConstraints;

    /// # Summary
    /// This program demonstrates solving Sudoku puzzle using Grovers algorithm
    /// To make it easier to understand, a 4x4 puzzle is solved with number 0 to 3,
    /// instead of usual 9x9 grid with numbers 1 to 9
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
    /// Sudoku is a graph coloring problem where graph edges must connect nodes of different colors
    /// In our case, Graph Nodes are puzzle squares and colors are the Sudoku numbers. 
    /// Graph Edges are the constraints preventing squares from having the same values. 
    /// In the above example, the constraints for the top row are
    ///   _________
    ///  | ______   \                   _____   
    ///  || __   \   \                  | __  \                        __
    /// _|||__\___\_ _\__         ______||__\___\__          _________|___\__ 
    /// |   | 1 |   | 3 |         |   | 1 |   | 3 |         |   | 1 |   | 3 | 
    /// -----------------         -----------------         -----------------
    ///
    /// To reduce the number of QuBits, we only use QuBits for empty squares.
    /// Each empty square gets 2 QuBits to encode the numbers 0 to 3
    /// We define the puzzle using 2 data structures.
    ///   - A list of edges connecting empty squares
    ///   - A list of constraints on empty squares to the initial numbers in the puzzle (starting numbers)
    /// For example, for the row above the empty squares have indexes
    /// _________________
    /// | 0 |   | 1 |   |
    /// -----------------
    /// and 
    /// emptySquareEdges = (0,1)         // cell#,cell# i.e. cell 0 can't have the same number as cell 1
    /// startingNumberConstraints = (0,1)  (0,3)  (1,1)  (1,3)   // cell#,constraint  e.g. empty cell 0 can't have value 1 or 3, and empty call #1 can't have values 1 or 3

    operation SolvePuzzle(V : Int, K : Int, size: Int, emptySquareEdges: (Int, Int)[], startingNumberConstraints: (Int, Int)[]) : (Bool, Int[]) {
        let numIterations = NIterations(V);
        Message($"Running Quantum test with #Vertex = {V}, Bits Per Color = {K}");
        Message($"   emptySquareEdges = {emptySquareEdges}");
        Message($"   startingNumberConstraints = {startingNumberConstraints}");
        Message($"   estimated #iterations needed = {numIterations}");
        Message($"   size of Sudoku grid = {size}x{size}");
        let coloring = GroversAlgorithm(V, K, numIterations*2, VertexColoringOracle(V, K, emptySquareEdges, startingNumberConstraints, _, _));

        Message($"Got sudoku solution: {coloring}");
        if (IsSudokuSolutionValid(V, size, emptySquareEdges, startingNumberConstraints, coloring)) {
           Message($"Got valid sudoku solution: {coloring}");
           return (true, coloring);
        } else {
           Message($"Got invalid sudoku solution: {coloring}");
           return (false, coloring);
        }
    }

    function NIterations(nQubits : Int) : Int {
        let nItems = 1 <<< nQubits; // 2^numQubits
        // compute number of iterations:
        let angle = ArcSin(1. / Sqrt(IntAsDouble(nItems)));
        let nIterations = Round(0.25 * PI() / angle - 0.5);
        return nIterations;
    }

    // verify solution is correct
    function IsSudokuSolutionValid (V : Int, size: Int, edges: (Int, Int)[], startingNumberConstraints: (Int, Int)[], colors: Int[]) : Bool {
        for (color in colors) {
            if (color > size) {
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