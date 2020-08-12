---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample uses Grover's search algorithm to solve Sudoku puzzles, an example of a quantum development technique known as amplitude amplification."

---

# Solving Sudoku using Grover's Algorithm


     This program demonstrates solving Sudoku puzzle using Grovers algorithm
     
     The code supports both 4x4 and 9x9 Sudoku puzzles.
          
     For 4x4 puzzles, the same rules apply
        - The numbers 0 to 3 may only appear once per row, column and 2x2 sub squares
     As an example              has solution
     _________________          _________________
     |   | 1 |   | 3 |          | 0 | 1 | 2 | 3 |  
     -----------------          -----------------
     | 2 |   |   | 1 |          | 2 | 3 | 0 | 1 |  
     -----------------          -----------------
     |   |   | 3 | 0 |          | 1 | 2 | 3 | 0 |  
     -----------------          -----------------
     | 3 |   | 1 |   |          | 3 | 0 | 1 | 2 |  
     -----------------          -----------------
    
     Sudoku is a graph coloring problem where graph edges must connect nodes of different colors
     In our case, Graph Nodes are puzzle squares and colors are the Sudoku numbers. 
     Graph Edges are the constraints preventing squares from having the same values. 
     In the above example, the constraints for the top row are
       _________
      | ______   \                   _____   
      || __   \   \                  | __  \                        __
     _|||__\___\_ _\__         ______||__\___\__          _________|___\__ 
     |   | 1 |   | 3 |         |   | 1 |   | 3 |         |   | 1 |   | 3 | 
     -----------------         -----------------         -----------------
    
     To reduce the number of QuBits, we only use QuBits for empty squares.
     Each empty square gets 2 QuBits to encode the numbers 0 to 3
     We define the puzzle using 2 data structures.
       - A list of edges connecting empty squares
       - A list of constraints on empty squares to the initial numbers in the puzzle (starting numbers)
     For example, for the row above the empty squares have indexes
     _________________
     | 0 |   | 1 |   |
     -----------------
     and emptySquareEdges is the array of edges e.g. cell 0 can't have the same number as cell 1
     emptySquareEdges = (0,1)      
     and startingNumberConstraints is the array of (Cell#,constraint) e.g. empty cell 0 can't have value 1 or 3
     startingNumberConstraints = (0,1)  (0,3)  (1,1)  (1,3)   
     
     Note that the puzzles are initially defined in C# using numbers from 1 to 4, or 1 to 9. 
     However, when solving with Quantum QuBits, the numbers are changed to 0 to 3 and 0 to 8 and then converted back. 
     This allows a 4x4 puzzle to be solved using 2 QuBits per number.

     The code can also solve 9x9 sudoku puzzles using 4 qubits per number. 
     However, trying to use more than 8 QuBits (2 empty squares) in a simulation becomes very slow, 
     so here we only run it for 1 or 2 missing squares in a 9x9 puzzle.


The graph coloring code is based on the [Graph Coloring Kata](https://github.com/microsoft/QuantumKatas/tree/master/GraphColoring) 
with changes to allow for varying QuBits per color and constraints on Vertex colors based on initial colors when you start.

## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample ##

To run the sample, use the `dotnet run` command from your terminal.

## Manifest ##

- [ColoringGroverWithConstraints.qs](ColoringGroverWithConstraints.qs): Q# code implementing graph coloring with flexible number of bits per color and ability to specify constraints on the colors found per Vertex.  A custom oracle for coloring with only 9 colors is also implemented.
- [Program.cs](Program.cs): C# code with Sudoku problems that it converts to arrays of edges and starting number constraints. It then calls the Q# code to get the results, and verifies they are correct. It also implements the classical C# code to solve a Sudoku puzzle.
- [Sudoku.qs](Sudoku.qs): Q# code which accepts edges and constraints and calls Grovers algorthm with the coloring oracle. Also checks the result is correct.
- [SimpleGroverSample.csproj](sudoku-grover.csproj): Main project for the sample.

## Sample Output ##

    dotnet run
    Solving 4x4 using classical computing
    -----------------
    |   | 2 |   | 4 |
    -----------------
    | 3 |   |   | 2 |
    -----------------
    |   |   | 4 | 1 |
    -----------------
    | 4 |   | 2 |   |
    -----------------
    result verified correct
    -----------------
    | 1 | 2 | 3 | 4 |
    -----------------
    | 3 | 4 | 1 | 2 |
    -----------------
    | 2 | 3 | 4 | 1 |
    -----------------
    | 4 | 1 | 2 | 3 |
    -----------------


    Press any key to continue...


    Quantum Solving 4x4 with 1 missing number
    Quantum solving puzzle 
    -----------------
    |   | 2 | 3 | 4 |
    -----------------
    | 3 | 4 | 1 | 2 |
    -----------------
    | 2 | 3 | 4 | 1 |
    -----------------
    | 4 | 1 | 2 | 3 |
    -----------------
    Running Quantum test with #Vertex = 1
    Bits Per Color = 2
    emptySquareEdges = []
    startingNumberConstraints = [(0, 2),(0, 1),(0, 3)]
    estimated #iterations needed = 1
    size of Sudoku grid = 4x4
    Trying search with 1 iterations
    Got sudoku solution: [0]
    Got valid sudoku solution: [0]
    solved puzzle 
    -----------------
    | 1 | 2 | 3 | 4 |
    -----------------
    | 3 | 4 | 1 | 2 |
    -----------------
    | 2 | 3 | 4 | 1 |
    -----------------
    | 4 | 1 | 2 | 3 |
    -----------------
    quantum result verified correct


    Press any key to continue...


    Quantum Solving 4x4 with 3 missing numbers
    Quantum solving puzzle 
    -----------------
    |   | 2 | 3 | 4 |
    -----------------
    | 3 |   | 1 | 2 |
    -----------------
    | 2 | 3 | 4 | 1 |
    -----------------
    | 4 |   | 2 | 3 |
    -----------------
    Running Quantum test with #Vertex = 3
    Bits Per Color = 2
    emptySquareEdges = [(1, 0),(2, 1)]
    startingNumberConstraints = [(0, 2),(0, 1),(0, 3),(1, 1),(1, 2),(1, 0),(2, 1),(2, 2),(2, 3)]
    estimated #iterations needed = 6
    size of Sudoku grid = 4x4
    Trying search with 1 iterations
    Trying search with 2 iterations
    Trying search with 3 iterations
    Got sudoku solution: [0,3,0]
    Got valid sudoku solution: [0,3,0]
    solved puzzle 
    -----------------
    | 1 | 2 | 3 | 4 |
    -----------------
    | 3 | 4 | 1 | 2 |
    -----------------
    | 2 | 3 | 4 | 1 |
    -----------------
    | 4 | 1 | 2 | 3 |
    -----------------
    quantum result verified correct


    Press any key to continue...


    Quantum Solving 4x4 with 4 missing numbers
    Quantum solving puzzle 
    -----------------
    |   |   | 3 | 4 |
    -----------------
    |   |   | 1 | 2 |
    -----------------
    | 2 | 3 | 4 | 1 |
    -----------------
    | 4 | 1 | 2 | 3 |
    -----------------
    Running Quantum test with #Vertex = 4
    Bits Per Color = 2
    emptySquareEdges = [(1, 0),(2, 0),(3, 0),(3, 1),(3, 2)]
    startingNumberConstraints = [(0, 1),(0, 3),(0, 2),(1, 2),(1, 0),(1, 3),(2, 1),(2, 3),(2, 0),(3, 2),(3, 0),(3, 1)]
    estimated #iterations needed = 12
    size of Sudoku grid = 4x4
    Trying search with 1 iterations
    Trying search with 2 iterations
    Trying search with 3 iterations
    Got sudoku solution: [0,1,2,3]
    Got valid sudoku solution: [0,1,2,3]
    solved puzzle 
    -----------------
    | 1 | 2 | 3 | 4 |
    -----------------
    | 3 | 4 | 1 | 2 |
    -----------------
    | 2 | 3 | 4 | 1 |
    -----------------
    | 4 | 1 | 2 | 3 |
    -----------------
    quantum result verified correct


    Press any key to continue...


    Solving 9x9 with 1 missing number using classical computing
    -------------------------------------
    |   | 7 | 3 | 8 | 9 | 4 | 5 | 1 | 2 |
    -------------------------------------
    | 9 | 1 | 2 | 7 | 3 | 5 | 4 | 8 | 6 |
    -------------------------------------
    | 8 | 4 | 5 | 6 | 1 | 2 | 9 | 7 | 3 |
    -------------------------------------
    | 7 | 9 | 8 | 2 | 6 | 1 | 3 | 5 | 4 |
    -------------------------------------
    | 5 | 2 | 6 | 4 | 7 | 3 | 8 | 9 | 1 |
    -------------------------------------
    | 1 | 3 | 4 | 5 | 8 | 9 | 2 | 6 | 7 |
    -------------------------------------
    | 4 | 6 | 9 | 1 | 2 | 8 | 7 | 3 | 5 |
    -------------------------------------
    | 2 | 8 | 7 | 3 | 5 | 6 | 1 | 4 | 9 |
    -------------------------------------
    | 3 | 5 | 1 | 9 | 4 | 7 | 6 | 2 | 8 |
    -------------------------------------
    classical test passed
    -------------------------------------
    | 6 | 7 | 3 | 8 | 9 | 4 | 5 | 1 | 2 |
    -------------------------------------
    | 9 | 1 | 2 | 7 | 3 | 5 | 4 | 8 | 6 |
    -------------------------------------
    | 8 | 4 | 5 | 6 | 1 | 2 | 9 | 7 | 3 |
    -------------------------------------
    | 7 | 9 | 8 | 2 | 6 | 1 | 3 | 5 | 4 |
    -------------------------------------
    | 5 | 2 | 6 | 4 | 7 | 3 | 8 | 9 | 1 |
    -------------------------------------
    | 1 | 3 | 4 | 5 | 8 | 9 | 2 | 6 | 7 |
    -------------------------------------
    | 4 | 6 | 9 | 1 | 2 | 8 | 7 | 3 | 5 |
    -------------------------------------
    | 2 | 8 | 7 | 3 | 5 | 6 | 1 | 4 | 9 |
    -------------------------------------
    | 3 | 5 | 1 | 9 | 4 | 7 | 6 | 2 | 8 |
    -------------------------------------


    Press any key to continue...


    Solving 9x9 with 1 missing number using Quantum Computing
    Quantum solving puzzle 
    -------------------------------------
    |   | 7 | 3 | 8 | 9 | 4 | 5 | 1 | 2 |
    -------------------------------------
    | 9 | 1 | 2 | 7 | 3 | 5 | 4 | 8 | 6 |
    -------------------------------------
    | 8 | 4 | 5 | 6 | 1 | 2 | 9 | 7 | 3 |
    -------------------------------------
    | 7 | 9 | 8 | 2 | 6 | 1 | 3 | 5 | 4 |
    -------------------------------------
    | 5 | 2 | 6 | 4 | 7 | 3 | 8 | 9 | 1 |
    -------------------------------------
    | 1 | 3 | 4 | 5 | 8 | 9 | 2 | 6 | 7 |
    -------------------------------------
    | 4 | 6 | 9 | 1 | 2 | 8 | 7 | 3 | 5 |
    -------------------------------------
    | 2 | 8 | 7 | 3 | 5 | 6 | 1 | 4 | 9 |
    -------------------------------------
    | 3 | 5 | 1 | 9 | 4 | 7 | 6 | 2 | 8 |
    -------------------------------------
    Running Quantum test with #Vertex = 1
    Bits Per Color = 4
    emptySquareEdges = []
    startingNumberConstraints = [(0, 8),(0, 7),(0, 6),(0, 4),(0, 0),(0, 3),(0, 1),(0, 2)]
    estimated #iterations needed = 3
    size of Sudoku grid = 9x9
    Trying search with 1 iterations
    Got sudoku solution: [5]
    Got valid sudoku solution: [5]
    solved puzzle 
    -------------------------------------
    | 6 | 7 | 3 | 8 | 9 | 4 | 5 | 1 | 2 |
    -------------------------------------
    | 9 | 1 | 2 | 7 | 3 | 5 | 4 | 8 | 6 |
    -------------------------------------
    | 8 | 4 | 5 | 6 | 1 | 2 | 9 | 7 | 3 |
    -------------------------------------
    | 7 | 9 | 8 | 2 | 6 | 1 | 3 | 5 | 4 |
    -------------------------------------
    | 5 | 2 | 6 | 4 | 7 | 3 | 8 | 9 | 1 |
    -------------------------------------
    | 1 | 3 | 4 | 5 | 8 | 9 | 2 | 6 | 7 |
    -------------------------------------
    | 4 | 6 | 9 | 1 | 2 | 8 | 7 | 3 | 5 |
    -------------------------------------
    | 2 | 8 | 7 | 3 | 5 | 6 | 1 | 4 | 9 |
    -------------------------------------
    | 3 | 5 | 1 | 9 | 4 | 7 | 6 | 2 | 8 |
    -------------------------------------
    quantum result verified correct


    Press any key to continue...


    Solving 9x9 with 2 missing numbers using Quantum Computing
    Quantum solving puzzle 
    -------------------------------------
    |   | 7 | 3 | 8 | 9 | 4 | 5 | 1 | 2 |
    -------------------------------------
    | 9 |   | 2 | 7 | 3 | 5 | 4 | 8 | 6 |
    -------------------------------------
    | 8 | 4 | 5 | 6 | 1 | 2 | 9 | 7 | 3 |
    -------------------------------------
    | 7 | 9 | 8 | 2 | 6 | 1 | 3 | 5 | 4 |
    -------------------------------------
    | 5 | 2 | 6 | 4 | 7 | 3 | 8 | 9 | 1 |
    -------------------------------------
    | 1 | 3 | 4 | 5 | 8 | 9 | 2 | 6 | 7 |
    -------------------------------------
    | 4 | 6 | 9 | 1 | 2 | 8 | 7 | 3 | 5 |
    -------------------------------------
    | 2 | 8 | 7 | 3 | 5 | 6 | 1 | 4 | 9 |
    -------------------------------------
    | 3 | 5 | 1 | 9 | 4 | 7 | 6 | 2 | 8 |
    -------------------------------------
    Running Quantum test with #Vertex = 2
    Bits Per Color = 4
    emptySquareEdges = [(1, 0)]
    startingNumberConstraints = [(0, 8),(0, 7),(0, 6),(0, 4),(0, 0),(0, 3),(0, 1),(0, 2),(1, 6),(1, 3),(1, 8),(1, 1),(1, 2),(1, 5),(1, 7),(1, 4)]
    estimated #iterations needed = 12
    size of Sudoku grid = 9x9
    Trying search with 1 iterations
    Trying search with 2 iterations
    Got sudoku solution: [5,0]
    Got valid sudoku solution: [5,0]
    solved puzzle 
    -------------------------------------
    | 6 | 7 | 3 | 8 | 9 | 4 | 5 | 1 | 2 |
    -------------------------------------
    | 9 | 1 | 2 | 7 | 3 | 5 | 4 | 8 | 6 |
    -------------------------------------
    | 8 | 4 | 5 | 6 | 1 | 2 | 9 | 7 | 3 |
    -------------------------------------
    | 7 | 9 | 8 | 2 | 6 | 1 | 3 | 5 | 4 |
    -------------------------------------
    | 5 | 2 | 6 | 4 | 7 | 3 | 8 | 9 | 1 |
    -------------------------------------
    | 1 | 3 | 4 | 5 | 8 | 9 | 2 | 6 | 7 |
    -------------------------------------
    | 4 | 6 | 9 | 1 | 2 | 8 | 7 | 3 | 5 |
    -------------------------------------
    | 2 | 8 | 7 | 3 | 5 | 6 | 1 | 4 | 9 |
    -------------------------------------
    | 3 | 5 | 1 | 9 | 4 | 7 | 6 | 2 | 8 |
    -------------------------------------
    quantum result verified correct


    Press any key to continue...


    Solving 9x9 with lots of missing number using classical computing
    -------------------------------------
    |   |   |   |   |   |   |   | 1 | 2 |
    -------------------------------------
    |   |   |   |   | 3 | 5 |   |   |   |
    -------------------------------------
    |   |   |   | 6 |   |   |   | 7 |   |
    -------------------------------------
    | 7 |   |   |   |   |   | 3 |   |   |
    -------------------------------------
    |   |   |   | 4 |   |   | 8 |   |   |
    -------------------------------------
    | 1 |   |   |   |   |   |   |   |   |
    -------------------------------------
    |   |   |   | 1 | 2 |   |   |   |   |
    -------------------------------------
    |   | 8 |   |   |   |   |   | 4 |   |
    -------------------------------------
    |   | 5 |   |   |   |   | 6 |   |   |
    -------------------------------------
    classical test passed
    -------------------------------------
    | 6 | 7 | 3 | 8 | 9 | 4 | 5 | 1 | 2 |
    -------------------------------------
    | 9 | 1 | 2 | 7 | 3 | 5 | 4 | 8 | 6 |
    -------------------------------------
    | 8 | 4 | 5 | 6 | 1 | 2 | 9 | 7 | 3 |
    -------------------------------------
    | 7 | 9 | 8 | 2 | 6 | 1 | 3 | 5 | 4 |
    -------------------------------------
    | 5 | 2 | 6 | 4 | 7 | 3 | 8 | 9 | 1 |
    -------------------------------------
    | 1 | 3 | 4 | 5 | 8 | 9 | 2 | 6 | 7 |
    -------------------------------------
    | 4 | 6 | 9 | 1 | 2 | 8 | 7 | 3 | 5 |
    -------------------------------------
    | 2 | 8 | 7 | 3 | 5 | 6 | 1 | 4 | 9 |
    -------------------------------------
    | 3 | 5 | 1 | 9 | 4 | 7 | 6 | 2 | 8 |
    -------------------------------------


    Press any key to continue...


    Solving 9x9 with lots of missing number using Quantum Computing - uncomment to test this