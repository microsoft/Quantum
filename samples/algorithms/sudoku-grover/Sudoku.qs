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

    //@EntryPoint()

    // operation Main(nQubits : Int) : Unit {
    //     if (nQubits == 2) {
    //         // problem #1 - 1 missing number
    //         // Puzzle to solve            Index of blank squares
    //         // _________________          _________________
    //         // |   | 1 | 2 | 3 |          | 0 |   |   |   |  
    //         // -----------------          -----------------
    //         // | 2 | 3 | 0 | 1 |          |   |   |   |   |  
    //         // -----------------          -----------------
    //         // | 1 | 2 | 3 | 0 |          |   |   |   |   |  
    //         // -----------------          -----------------
    //         // | 3 | 0 | 1 | 2 |          |   |   |   |   |  
    //         // -----------------          -----------------
    //         // solution is (0)  i.e. empty cell 0 has value 0
    //         let emptySquareEdges = new (Int,Int)[0
    //         ];
    //         // Starting Number constraints on blank squares
    //         let startingNumberConstraints = [
    //             // horizontal constraints e.g. cell #0 can't have value 1, 2 or 3 
    //             (0,1),(0,2),(0,3)
    //             // vertical constraints -- already have from horizontal constraints
    //             // (0,2),(0,1),(0,3),
    //             // 2x2 diagonal constraints -- already have from horizontal constraints
    //             // (0,3)
    //         ];
    //         let V = 1;    // 1 empty square 
    //         let result = SolvePuzzle(V, 2, emptySquareEdges, startingNumberConstraints);
    //     } elif (nQubits == 6) {
    //         // problem #2 - 3 missing numbers
    //         // Puzzle to solve            Index of blank squares
    //         // _________________          _________________
    //         // |   | 1 | 2 | 3 |          | 0 |   |   |   |  
    //         // -----------------          -----------------
    //         // | 2 |   | 0 | 1 |          |   | 1 |   |   |  
    //         // -----------------          -----------------
    //         // | 1 | 2 | 3 | 0 |          |   |   |   |   |  
    //         // -----------------          -----------------
    //         // | 3 |   | 1 | 2 |          |   | 2 |   |   |  
    //         // -----------------          -----------------
    //         // The values of the blank squares (0,1,2) = (0,3,0)  i.e. empty cell #0 has value 0, empty cell #1 has value 3, empty cell #2 has value 0
    //         let emptySquareEdges = [
    //             // vertical edges
    //             (1,2),     // empty cell #1 can not have same value as cell #2
    //             // 2x2 diagonals
    //             (0,1)      // empty cell #0 can not have same value as cell #1
    //         ];
    //         // Starting Number constraints on blank squares
    //         let startingNumberConstraints = [
    //             // horizontal constraints e.g. cell #0 can't have value 1, 2 or 3 
    //             (0,1),(0,2),(0,3),
    //             (1,2),(1,0),(1,1),
    //             (2,3),(2,1),(2,2)
    //             // vertical constraints
    //             // (0,2),(0,1),(0,3), -- already have from horiz constraints
    //             // (1,1),(1,2),(2,1),(2,2), -- already have from horiz constraints
    //             // 2x2 diagonal constraints e.g. empty call #2 can not have value 1
    //             // (2,1) -- already have from horiz constraints
    //         ];
    //         let V = 3;    // 3 empty squares 
    //         let result = SolvePuzzle(V, 2, emptySquareEdges, startingNumberConstraints);
    //     } elif (nQubits == 8) {  
    //         // problem #3 - 4 missing numbers
    //         // Puzzle to solve            Index of blank squares
    //         // _________________          _________________
    //         // |   | 1 |   | 3 |          | 0 |   | 1 |   |  
    //         // -----------------          -----------------
    //         // | 2 |   |   | 1 |          |   | 2 | 3 |   |  
    //         // -----------------          -----------------
    //         // | 1 | 2 | 3 | 0 |          |   |   |   |   |  
    //         // -----------------          -----------------
    //         // | 3 | 0 | 1 | 2 |          |   |   |   |   |  
    //         // -----------------          -----------------
    //         // The values of the blank squares (0,1,2,3) are (0,2,3,0) i.e. empty cell #0 has value 0 etc
    //         let emptySquareEdges = [
    //             // horizontal edges e.g. empty cell #0 can't have same value as cell #1
    //             (0,1),  
    //             (2,3),
    //             // vertical edges
    //             (1,3),
    //             // diagonal
    //             (0,2)
    //         ];
    //         let startingNumberConstraints = [
    //             // horizontal constraints e.g. cell#0 can't have value 1 or 3
    //             (0,1),(0,3),
    //             (2,2),(2,1),(3,2),(3,1),
    //             // vertical constraints
    //             (0,2),                 // (0,1),(0,3),  -- already have from horiz constraint
    //             (2,0),                 // (2,1),(2,2),  -- already have from horiz constraint
    //             (1,3),(1,1),(3,3),     // (3,1) -- already have from horiz constraint
    //             // 2x2 diagonal constraints e.g. empty cell #1 can't have value 1 
    //             (1,1)  // (3,3),
    //        ];
    //        let V = 4;  // 4 empty squares
    //        let result = SolvePuzzle(V, 2, emptySquareEdges, startingNumberConstraints);
    //     } elif (nQubits == 10) {  
    //         // problem #4 - 5 missing numbers
    //         // Puzzle to solve            Index of blank squares
    //         // _________________          _________________
    //         // |   | 1 |   | 3 |          | 0 |   | 1 |   |  
    //         // -----------------          -----------------
    //         // | 2 |   |   | 1 |          |   | 2 | 3 |   |  
    //         // -----------------          -----------------
    //         // | 1 |   | 3 | 0 |          |   | 4 |   |   |  
    //         // -----------------          -----------------
    //         // | 3 | 0 | 1 | 2 |          |   |   |   |   |  
    //         // -----------------          -----------------
    //         // The values of the blank squares (0,1,2,3,4) are (0,2,3,0,2) i.e. empty cell #0 has value 0 etc
    //         let emptySquareEdges = [
    //             // horizontal edges e.g. empty cell #0 can't have same value as cell #1
    //             (0,1),  
    //             (2,3),
    //             // vertical edges
    //             (2,4),
    //             (1,3),
    //             // diagonal
    //             (0,2)
    //         ];
    //         let startingNumberConstraints = [
    //             // horizontal constraints e.g. cell#0 can't have value 1 or 3
    //             (0,1),(0,3),
    //             (2,2),(2,1),(3,2),(3,1),
    //             (4,1),(4,3),(4,0),
    //             // vertical constraints
    //             (0,2),  // (0,1),(0,3), -- already have from horiz constraint
    //             (2,0),        // (2,1),(4,1),(4,0) -- already have from horiz constraint
    //             (1,3),(1,1),(3,3),         // (3,1) -- already have from horiz constraint
    //             // 2x2 diagonal constraints e.g. empty cell #1 can't have value 1 
    //             (1,1)  // (3,3),
    //             // (4,3)
    //        ];
    //        let V = 5;  // 5 empty squares
    //        let result = SolvePuzzle(V, 2, emptySquareEdges, startingNumberConstraints);           
    //     } elif (nQubits == 14) {  
    //         // problem #4 - 7 missing numbers
    //         // Puzzle to solve            Index of blank squares
    //         // _________________          _________________
    //         // |   | 1 |   | 3 |          | 0 |   | 1 |   |  
    //         // -----------------          -----------------
    //         // | 2 |   |   | 1 |          |   | 2 | 3 |   |  
    //         // -----------------          -----------------
    //         // |   |   | 3 | 0 |          | 4 | 5 |   |   |  
    //         // -----------------          -----------------
    //         // | 3 |   | 1 | 2 |          |   | 6 |   |   |  
    //         // -----------------          -----------------
    //         // The values of the blank squares (0,1,2,3,4,5,6) are (0,2,3,0,1,2,0) i.e. empty cell #0 has value 0 etc
    //         let emptySquareEdges = [
    //             // horizontal edges e.g. empty cell #0 can't have same value as cell #1
    //             (0,1),   
    //             (2,3),
    //             (4,5),
    //             // vertical edges
    //             (0,4),
    //             (2,5),(2,6),(5,6),
    //             (1,3),
    //             // diagonal
    //             (0,2),
    //             (4,6)
    //         ];
    //         let startingNumberConstraints = [
    //             // horizontal constraints e.g. cell#0 can't have value 1 or 3
    //             (0,1),(0,3),(1,1),(1,3),
    //             (2,2),(2,1),(3,2),(3,1),
    //             (4,3),(4,0),(5,3),(5,0),
    //             (6,3),(6,1),(6,2),
    //             // vertical constraints
    //             (0,2),(4,2),  // (0,3),(4,3), -- already have from horiz constraint
    //             (5,1),        // (2,1),(6,1), -- already have from horiz constraint
    //             (3,3)         // (1,3),(1,1),(3,1), -- already have from horiz constraint
    //             // 2x2 diagonal constraints e.g. empty cell #1 can't have value 1 
    //             // already have these constraints from above
    //             // (1,1),(3,3),  
    //             // (5,3)
    //        ];
    //        let V = 7;  // 7 empty squares
    //        let result = SolvePuzzle(V, 2, emptySquareEdges, startingNumberConstraints);
    //     } else {  
    //         // problem #5 - 8 missing numbers
    //         // Puzzle to solve            Index of blank squares
    //         // _________________          _________________
    //         // |   | 1 |   | 3 |          | 0 |   | 1 |   |  
    //         // -----------------          -----------------
    //         // | 2 |   |   | 1 |          |   | 2 | 3 |   |  
    //         // -----------------          -----------------
    //         // |   |   | 3 | 0 |          | 4 | 5 |   |   |  
    //         // -----------------          -----------------
    //         // | 3 |   | 1 |   |          |   | 6 |   | 7 |  
    //         // -----------------          -----------------
    //         // The values of the blank squares (0,1,2,3,4,5,6,7) are (0,2,3,0,1,2,0,2) i.e. empty cell #0 has value 0 etc
    //         let emptySquareEdges = [
    //             // horizontal edges e.g. empty cell #0 can't have same value as cell #1
    //             (0,1),   
    //             (2,3),
    //             (4,5),
    //             (6,7),
    //             // vertical edges
    //             (0,4),
    //             (2,5),(2,6),(5,6),
    //             (1,3),
    //             // diagonal
    //             (0,2),
    //             (4,6)
    //         ];
    //         let startingNumberConstraints = [
    //             // horizontal constraints e.g. cell#0 can't have value 1 or 3
    //             (0,1),(0,3),(1,1),(1,3),
    //             (2,2),(2,1),(3,2),(3,1),
    //             (4,3),(4,0),(5,3),(5,0),
    //             (6,3),(6,1),(7,3),(7,1),
    //             // vertical constraints
    //             (0,2),(4,2),  // ,(0,3),(4,3), -- already have from horiz constraint
    //             (5,1),        // (2,1),(6,1), -- already have from horiz constraint
    //             (3,3),        // (1,3),(1,1),(3,1), -- already have from horiz constraint
    //             (7,0)        // (7,3),(7,1), -- already have from horiz constraint
    //             // 2x2 diagonal constraints e.g. empty cell #1 can't have value 1 
    //             // already have these constraints from above
    //             // (1,1),(3,3),  
    //             // (5,3),
    //             // (7,3)
    //        ];
    //        let V = 8;  // 8 empty squares
    //        let result = SolvePuzzle(V, 2, emptySquareEdges, startingNumberConstraints);
    //     }
    // }

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
        // for (color in colors) {
        //     if (color > size) {
        //         return false;
        //     }
        // }
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