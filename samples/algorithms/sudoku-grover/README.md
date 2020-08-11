---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample implements Grover's search algorithm to solve Sudoku puzzles, an example of a quantum development technique known as amplitude amplification."
---

# Searching with Grover's Algorithm

This sample implements Grover's search algorithm, an example of a quantum development technique known as _amplitude amplification_.
Oracles implementing the database are explicitly constructed together with all steps of the algorithm.
See the [DatabaseSearch](https://github.com/microsoft/Quantum/blob/master/samples/algorithms/database-search/README.md) sample for and extended version and the [Grover Search Kata](https://github.com/microsoft/QuantumKatas/tree/master/GroversAlgorithm) to learn more about Grover's algorithm and how to implement it in Q#.

This sample uses the example of an operation that marks inputs of the form "010101…", then uses Grover's algorithm to find these inputs given only the ability to call that operation.
In this case, the sample uses a hard-coded operation, but operations and functions in the [Microsoft.Quantum.AmplitudeAmplification namespace](https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.amplitudeamplification) can be used to efficiently and easily construct different inputs to Grover's algorithm, and to quickly build up useful variations of amplitude amplification for different applications.
For examples of how to solve more general problems using amplitude amplification, check out the more in-depth [database search sample](https://github.com/microsoft/Quantum/tree/master/samples/algorithms/database-search).

     This program demonstrates solving Sudoku puzzle using Grovers algorithm
     To make it easier to understand, a 4x4 puzzle is solved with number 0 to 3,
     instead of usual 9x9 grid with numbers 1 to 9
     However, the same rules apply
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
     and 
     emptySquareEdges = (0,1)         // cell#,cell# i.e. cell 0 can't have the same number as cell 1
     startingNumberConstraints = (0,1)  (0,3)  (1,1)  (1,3)   // cell#,constraint  e.g. empty cell 0 can't have value 1 or 3, and empty call #1 can't have values 1 or 3

     Note that the puzzles are initially defined in C# using numbers from 1 to 4, or 1 to 9. However, when solving with Quantum QuBits, the numbers are changed to 0 to 3 and 0 to 8 and then converted back. This allows a 4x4 puzzle to be solved using 2 QuBits per number.

     The code can also solve 9x9 sudoku puzzles using 3 qubits per number. However, trying to use more than 6 or 7 QuBits in a simulation becomes very slow, so you can only run it for 2 missing squares in a 9x9 puzzle.


## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample ##

To run the sample, use the `dotnet run` command from your terminal.

## Manifest ##

- [ColoringGroverWithConstraints.qs](https://github.com/microsoft/Quantum/blob/master/samples/algorithms/sudoku-grover/ColoringGroverWithConstraints.qs): Q# code implementing quantum operations for this sample.
- [Reflections.qs](https://github.com/microsoft/Quantum/blob/master/samples/algorithms/sudoku-grover/Sudoku.qs): Q# code implementing quantum operations for this sample.
- [SimpleGroverSample.csproj](https://github.com/microsoft/Quantum/blob/master/samples/algorithms/sudoku-grover/sudoku-grover.csproj): Main project for the sample.

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
classical test passed
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
Running test with #Vertex = 1, Bits Per Color = 2
   emptySquareEdges = []
   startingNumberConstraints = [(0, 2),(0, 1),(0, 3)]
   estimated #iterations needed = 1
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
Running test with #Vertex = 3, Bits Per Color = 2
   emptySquareEdges = [(1, 0),(2, 1)]
   startingNumberConstraints = [(0, 2),(0, 1),(0, 3),(1, 1),(1, 2),(1, 0),(2, 1),(2, 2),(2, 3)]
   estimated #iterations needed = 2
Trying search with 1 iterations
Trying search with 2 iterations
Trying search with 3 iterations
Trying search with 4 iterations
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
Running test with #Vertex = 4, Bits Per Color = 2
   emptySquareEdges = [(1, 0),(2, 0),(3, 0),(3, 1),(3, 2)]
   startingNumberConstraints = [(0, 1),(0, 3),(0, 2),(1, 2),(1, 0),(1, 3),(2, 1),(2, 3),(2, 0),(3, 2),(3, 0),(3, 1)]
   estimated #iterations needed = 3
Trying search with 1 iterations
Trying search with 2 iterations
Trying search with 3 iterations
Trying search with 4 iterations
Trying search with 5 iterations
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


Press any key to continue...


 Solving 9x9 with 2 missing numbers using classical computing
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
Running test with #Vertex = 2, Bits Per Color = 4
   emptySquareEdges = [(1, 0)]
   startingNumberConstraints = [(0, 8),(0, 7),(0, 6),(0, 4),(0, 0),(0, 3),(0, 1),(0, 2),(1, 6),(1, 3),(1, 8),(1, 1),(1, 2),(1, 5),(1, 7),(1, 4)]
   estimated #iterations needed = 1
Trying search with 1 iterations
Got sudoku solution: [10,15]
Got valid sudoku solution: [10,15]
solved puzzle 
-------------------------------------
| 11 | 7 | 3 | 8 | 9 | 4 | 5 | 1 | 2 |
-------------------------------------
| 9 | 16 | 2 | 7 | 3 | 5 | 4 | 8 | 6 |
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