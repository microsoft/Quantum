// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.SudokuGrover
{
    class Program
    {
        /// # Summary
        /// Main entry point
        ///
        /// # Inputs
        /// ## args
        /// add the following argument to specify which puzzles to run
        /// -  `all` or blank : run all puzzles (default)
        /// -  `4x4-classic` : test classic algorthm on a 4x4 puzzle
        /// -  `4x4-1` : test Quantum solution of 4x4 puzzle missing 1 number
        /// -  `4x4-3` : test Quantum solution of 4x4 puzzle missing 3 numbers
        /// -  `4x4-4` : test Quantum solution of 4x4 puzzle missing 4 numbers
        /// -  `9x9-1` : test classic algorithm and Quantum solution on a 
        ///              9x9 puzzle with 1 missing number
        /// -  `9x9-2` : test Quantum solution on a 
        ///              9x9 puzzle with 2 missing numbers
        /// -  `9x9-64` : test classic algorithm and Quantum solution on a 
        ///              9x9 puzzle with 64 missing numbers
        static void Main(string[] args)
        {
            string puzzleToRun = args.Length > 0 ? args[0] : "all";

            var sim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true);

            int[,] answer4 = {
                { 1,2,3,4 },
                { 3,4,1,2 },
                { 2,3,4,1 },
                { 4,1,2,3 } };

            int[,] answer9 = {
                { 6,7,3, 8,9,4, 5,1,2 },
                { 9,1,2, 7,3,5, 4,8,6 },
                { 8,4,5, 6,1,2, 9,7,3 },
                { 7,9,8, 2,6,1, 3,5,4 },
                { 5,2,6, 4,7,3, 8,9,1 },
                { 1,3,4, 5,8,9, 2,6,7 },
                { 4,6,9, 1,2,8, 7,3,5 },
                { 2,8,7, 3,5,6, 1,4,9 },
                { 3,5,1, 9,4,7, 6,2,8} };

            if (puzzleToRun == "4x4-classic" || puzzleToRun == "all") 
            {
                // Test solving a 4x4 Sudoku puzzle using classical computing
                // missing numbers are denoted by 0
                int[,] puzzle4 = {
                    { 0,2,0,4 },
                    { 3,0,0,2 },
                    { 0,0,4,1 },
                    { 4,0,2,0 } };
                Console.WriteLine("Solving 4x4 using classical computing");
                ShowGrid(puzzle4, 4);
                SolveSudukoClassic(puzzle4, 4, 2);
                bool good = puzzle4.Cast<int>().SequenceEqual(answer4.Cast<int>());
                if (good)
                    Console.WriteLine("result verified correct");
                ShowGrid(puzzle4, 4);
                Pause();
            }
            if (puzzleToRun == "4x4-1" || puzzleToRun == "all") 
            {
                // Testing solving an easy 4x4 puzzle with only 1 missing number with Quantum
                Console.WriteLine("Quantum Solving 4x4 with 1 missing number");
                int[,] puzzle4_1 = {
                    { 0,2,3,4 },
                    { 3,4,1,2 },
                    { 2,3,4,1 },
                    { 4,1,2,3 } };
                QuantumSolve(puzzle4_1, 4, 2, sim);
                bool good = puzzle4_1.Cast<int>().SequenceEqual(answer4.Cast<int>());
                if (good)
                    Console.WriteLine("quantum result verified correct");
                Pause();
            }
            if (puzzleToRun == "4x4-3" || puzzleToRun == "all") 
            {
                // Test 4x4 puzzle with 3 missing numbers with Quantum
                Console.WriteLine("Quantum Solving 4x4 with 3 missing numbers");
                int[,] puzzle4_3 = {
                    { 0,2,3,4 },
                    { 3,0,1,2 },
                    { 2,3,4,1 },
                    { 4,0,2,3 } };
                QuantumSolve(puzzle4_3, 4, 2, sim);
                bool good = puzzle4_3.Cast<int>().SequenceEqual(answer4.Cast<int>());
                if (good)
                    Console.WriteLine("quantum result verified correct");
                Pause();
            }
            if (puzzleToRun == "4x4-4" || puzzleToRun == "all") 
            {
                // Test 4x4 puzzle with 4 missing numbers with Quantum
                Console.WriteLine("Quantum Solving 4x4 with 4 missing numbers");
                int[,] puzzle4_4 = {
                    { 0,0,3,4 },
                    { 0,0,1,2 },
                    { 2,3,4,1 },
                    { 4,1,2,3 } };
                QuantumSolve(puzzle4_4, 4, 2, sim);
                bool good = puzzle4_4.Cast<int>().SequenceEqual(answer4.Cast<int>());
                if (good)
                    Console.WriteLine("quantum result verified correct");
                Pause();
            }
            if (puzzleToRun == "9x9-1" || puzzleToRun == "all") 
            {
                // Test 9x9 puzzle with classical and quantum - 1 missing number
                int[,] puzzle9_1 = {
                    { 0,7,3, 8,9,4, 5,1,2 },
                    { 9,1,2, 7,3,5, 4,8,6 },
                    { 8,4,5, 6,1,2, 9,7,3 },
                    { 7,9,8, 2,6,1, 3,5,4 },
                    { 5,2,6, 4,7,3, 8,9,1 },
                    { 1,3,4, 5,8,9, 2,6,7 },
                    { 4,6,9, 1,2,8, 7,3,5 },
                    { 2,8,7, 3,5,6, 1,4,9 },
                    { 3,5,1, 9,4,7, 6,2,8} };
                int[,] puzzle9_1_copy = CopyIntArray(puzzle9_1, 9);
                Console.WriteLine("Solving 9x9 with 1 missing number using classical computing");
                ShowGrid(puzzle9_1, 9);
                SolveSudukoClassic(puzzle9_1, 9, 3);
                bool good = puzzle9_1.Cast<int>().SequenceEqual(answer9.Cast<int>());
                if (!good)
                    Console.WriteLine("classical test failed");
                else
                {
                    Console.WriteLine("classical test passed");
                    ShowGrid(puzzle9_1, 9);
                }
                Pause();
                Console.WriteLine("Solving 9x9 with 1 missing number using Quantum Computing");
                QuantumSolve(puzzle9_1_copy, 9, 3, sim);
                good = puzzle9_1_copy.Cast<int>().SequenceEqual(answer9.Cast<int>());
                if (good)
                    Console.WriteLine("quantum result verified correct");
                Pause();
            }
            if (puzzleToRun == "9x9-2" || puzzleToRun == "all") 
            {
                // Test 9x9 puzzle with quantum - 2 missing number
                int[,] puzzle9_2 = {
                    { 0,7,3, 8,9,4, 5,1,2 },
                    { 9,0,2, 7,3,5, 4,8,6 },
                    { 8,4,5, 6,1,2, 9,7,3 },
                    { 7,9,8, 2,6,1, 3,5,4 },
                    { 5,2,6, 4,7,3, 8,9,1 },
                    { 1,3,4, 5,8,9, 2,6,7 },
                    { 4,6,9, 1,2,8, 7,3,5 },
                    { 2,8,7, 3,5,6, 1,4,9 },
                    { 3,5,1, 9,4,7, 6,2,8} };
                Console.WriteLine("Solving 9x9 with 2 missing numbers using Quantum Computing");
                QuantumSolve(puzzle9_2, 9, 3, sim);
                var good = puzzle9_2.Cast<int>().SequenceEqual(answer9.Cast<int>());
                if (good)
                    Console.WriteLine("quantum result verified correct");
                Pause();
            }
            if (puzzleToRun == "9x9-64" || puzzleToRun == "all") 
            {
                // Test hard 9x9 puzzle with classical and quantum 
                int[,] puzzle9 = {
                    { 0,0,0, 0,0,0, 0,1,2 },
                    { 0,0,0, 0,3,5, 0,0,0 },
                    { 0,0,0, 6,0,0, 0,7,0 },
                    { 7,0,0, 0,0,0, 3,0,0 },
                    { 0,0,0, 4,0,0, 8,0,0 },
                    { 1,0,0, 0,0,0, 0,0,0 },
                    { 0,0,0, 1,2,0, 0,0,0 },
                    { 0,8,0, 0,0,0, 0,4,0 },
                    { 0,5,0, 0,0,0, 6,0,0 } };
                int[,] puzzle9_copy = CopyIntArray(puzzle9, 9);
                Console.WriteLine("Solving 9x9 with 64 missing numbers using classical computing");
                ShowGrid(puzzle9, 9);
                SolveSudukoClassic(puzzle9, 9, 3);
                bool good = puzzle9.Cast<int>().SequenceEqual(answer9.Cast<int>());
                if (!good)
                    Console.WriteLine("classical test failed");
                else
                {
                    Console.WriteLine("classical test passed");
                    ShowGrid(puzzle9, 9);
                }
                Pause();
                Console.WriteLine("Solving 9x9 with 64 missing numbers using Quantum Computing. Cntrl-C to stop");
                QuantumSolve(puzzle9_copy, 9, 3, sim);
                good = puzzle9_copy.Cast<int>().SequenceEqual(answer9.Cast<int>());
                if (good)
                    Console.WriteLine("quantum result verified correct");
                Pause();
            }
            Console.WriteLine("finished");

        }

        // An Empty square with its row and column
        public class EmptySquare
        {
            public int i, j;
        }

        /// # Summary
        /// Copy an Int 2 dimensional array
        ///
        /// # Input
        /// ## org
        /// The array to copy
        /// ## size
        /// The size of the array
        ///
        /// # Output
        /// A copy of the array
        public static int[,] CopyIntArray(int[,] org, int size)
        {
            int[,] result = new int[size, size];
            for (int i = 0; i < size; i++)
                for (int j = 0; j < size; j++)
                    result[i, j] = org[i, j];
            return result;
        }
 
        /// # Summary
        /// QuantumSolve will call Q# code to solve the Sudoku puzzle and display the solution
        /// # Input
        /// ## puzzle
        /// The Sudoku puzzle to solve
        /// ## size
        /// The size of the puzzle is either 4 (for 4x4) or 9 (for 9x9)
        /// ## subsize
        /// subsize is 2 for 4x4 and 3 for 9x9
        /// ## sim
        /// The quantum simulator
        public static void QuantumSolve(int[,] puzzle, int size, int subSize, QuantumSimulator sim)
        {
            List<ValueTuple<long, long>> emptySquareEdges;
            HashSet<ValueTuple<long, long>> startingNumberConstraints;
            List<EmptySquare> emptySquares;
            FindEdgesAndInitialNumberConstraints(puzzle, size, subSize, out emptySquareEdges, out startingNumberConstraints, out emptySquares);
            var emptySquareEdgesQArray = new QArray<ValueTuple<long, long>>(emptySquareEdges);
            var startingNumberConstraintsQArray = new QArray<ValueTuple<long, long>>(startingNumberConstraints);
            Console.WriteLine("Quantum solving puzzle ");
            ShowGrid(puzzle, size);
            var task = SolvePuzzle.Run(sim, emptySquares.Count, size, emptySquareEdgesQArray, startingNumberConstraintsQArray);
            if (!task.Result.Item1)
                Console.WriteLine("no solution found ");
            else
            {
                var solution = task.Result.Item2.ToArray();
                for (int i = 0; i < solution.Length; i++)
                {
                    puzzle[emptySquares[i].i, emptySquares[i].j] = (int)solution[i] + 1;
                }
                Console.WriteLine("solved puzzle ");
                ShowGrid(puzzle, size);
            }
        }

        /// # Summary
        /// Display the puzzle
        public static void ShowGrid(int[,] puzzle, int size)
        {
            for (int i = 0; i < size; i++)
            {
                for (int j = 0; j < size; j++)
                    Console.Write("----");
                Console.WriteLine("-");
                for (int j = 0; j < size; j++) 
                {
                    if (puzzle[i, j] == 0)
                        Console.Write("|   ");
                    else
                        Console.Write(String.Format("| {0,1} ", puzzle[i, j]));
                }
                Console.WriteLine("|");
            }
            for (int j = 0; j < size; j++)
                    Console.Write("----");
            Console.WriteLine("-");
        }

        /// # Summary
        /// find the puzzle empty square edges, and starting number constraints for those empty squares
        ///
        /// # Input
        /// ## puzzle
        /// The Sudoku puzzle
        /// ## size
        /// The size of the puzzle. For example, 9 for a 9x9 puzzle
        /// 
        /// # Output
        /// ## emptySquareEdges
        /// The list of empty square edges specifying Vertices in the same row/col/subgrid
        /// ## startingNumberConstraints
        /// The set of numbers that this empty square can not have. 
        /// ## emptySquares
        /// list of empty squares with their i,j locations
        public static void FindEdgesAndInitialNumberConstraints(int[,] puzzle, int size, int subSize,
            out List<ValueTuple<long, long>> emptySquareEdges, out HashSet<ValueTuple<long, long>> startingNumberConstraints,
            out List<EmptySquare> emptySquares)
        {
            // find color edges ... i.e. edges between horizontal, vertical and diagonal empty squares
            // note that for size=4, we will subtract 1 from all puzzle numbers so that they fit in 2 bits i.e. 1 to 4 becomes 0 to 3
            int[,] emptyIndexes = new int[size, size];
            emptySquares = new List<EmptySquare>();
            emptySquareEdges = new List<ValueTuple<long, long>>();
            // Starting Number constraints on blank squares
            startingNumberConstraints = new HashSet<ValueTuple<long, long>>();

            for (int i = 0; i < size; i++)
            {
                for (int j = 0; j < size; j++)
                {
                    if (puzzle[i, j] == 0)
                    {
                        int emptyIndex = emptySquares.Count;
                        emptyIndexes[i, j] = emptyIndex;
                        EmptySquare emptySquare = new EmptySquare();
                        emptySquare.i = i;
                        emptySquare.j = j;
                        emptySquares.Add(emptySquare);
                        // add all existing number constraints in subSize x subSize to hashset of constraints for this cell
                        // Also, add edge to any previous empty cells in the subSize x subSize box
                        int iSubGridStart = i / subSize * subSize;
                        int jSubGridStart = j / subSize * subSize;
                        for (int iSub = iSubGridStart; iSub < i; iSub++)
                        {
                            for (int jSub = jSubGridStart; jSub < j; jSub++)
                            {
                                if (puzzle[iSub, jSub] != 0)
                                    startingNumberConstraints.Add(ValueTuple.Create(emptyIndex, puzzle[iSub, jSub] - 1));
                                else if (iSub < i && jSub < j)
                                    emptySquareEdges.Add(ValueTuple.Create(emptyIndex, emptyIndexes[iSub, jSub]));
                            }
                        }
                        for (int ii = 0; ii < size; ii++)
                        {
                            if (puzzle[ii, j] != 0)
                                startingNumberConstraints.Add(ValueTuple.Create(emptyIndex, puzzle[ii, j] - 1));
                            else if (ii < i)
                                emptySquareEdges.Add(ValueTuple.Create(emptyIndex, emptyIndexes[ii, j]));
                        }
                        for (int jj = 0; jj < size; jj++)
                        {
                            if (puzzle[i, jj] != 0)
                                startingNumberConstraints.Add(ValueTuple.Create(emptyIndex, puzzle[i, jj] - 1));
                            else if (jj < j)
                                emptySquareEdges.Add(ValueTuple.Create(emptyIndex, emptyIndexes[i, jj]));
                        }
                    }
                }
            }
        }

        /// # Summary
        /// Pause execution with a message and wait for a key to be pressed to continue
        public static void Pause()
        {
            System.Console.WriteLine("\n\nPress any key to continue...\n\n");
            System.Console.ReadKey();
        }

        /// # Summary
        /// Classical Sudoku solution using Recursive Depth First Search 
        /// ## puzzle
        /// The Sudoku puzzle
        /// ## size
        /// The size of the puzzle i.e. 4 or 9
        /// ## subSize
        /// The size of the subGrids i.e. if size = 9, subSize = 3
        static bool SolveSudukoClassic(int[,] puzzle, int size, int subSize)
        {
            // find empty cell will least possible options and try each
            Candidate emptyCell = BestSquare(puzzle, size, subSize);
            if (emptyCell == null)
                return true; // no more empty cells --- success!!
            if (emptyCell.possibleValues.Count == 0)
                return false; // there's an empty cell, but no possible values -- dead end
            foreach (int possibleValue in emptyCell.possibleValues)
            {
                puzzle[emptyCell.i, emptyCell.j] = possibleValue;
                bool result = SolveSudukoClassic(puzzle, size, subSize);
                if (result)
                    return true;
            }
            // we tried all values and none worked  -- dead end
            puzzle[emptyCell.i, emptyCell.j] = 0;
            return false;
        }

        /// # Summary
        /// For classical sudoku, Candidate is an empty square and the possible values it can take
        class Candidate
        {
            public int i;
            public int j;
            public List<int> possibleValues = new List<int>();
        }

        /// # Summary
        /// For classical sudoku, go thru entire puzzle and find all empty squares and, 
        /// for each, the possible numbers for that square
        /// 
        /// # Input
        /// ## puzzle
        /// The Sudoku puzzle
        /// ## size
        /// The size of the puzzle i.e. 4 or 9
        /// ## subSize
        /// The size of the subGrids i.e. if size = 9, subSize = 3
        static Candidate BestSquare(int[,] puzzle, int size, int subSize)
        {
            List<Candidate> candidates = new List<Candidate>();
            for (int i = 0; i < size; i++)
            {
                for (int j = 0; j < size; j++)
                {
                    if (puzzle[i, j] == 0)
                    {
                        Candidate candidate = new Candidate();
                        candidate.i = i;
                        candidate.j = j;
                        candidates.Add(candidate);
                        HashSet<int> dissallowedValues = new HashSet<int>();
                        // add all numbers in subSize x subSize to hashset
                        int iSubGridStart = i / subSize * subSize;
                        int jSubGridStart = j / subSize * subSize;
                        for (int iSub = iSubGridStart; iSub < iSubGridStart + subSize; iSub++)
                        {
                            for (int jSub = jSubGridStart; jSub < jSubGridStart + subSize; jSub++)
                            {
                                if (puzzle[iSub, jSub] != 0)
                                    dissallowedValues.Add(
                                        puzzle[iSub, jSub]);
                            }
                        }
                        // add all numbers in this row to hashset
                        for (int ii = 0; ii < size; ii++)
                            if (puzzle[ii, j] != 0)
                                dissallowedValues.Add(puzzle[ii, j]);
                        // add all numbers in this col to hashset
                        for (int jj = 0; jj < size; jj++)
                            if (puzzle[i, jj] != 0)
                                dissallowedValues.Add(puzzle[i, jj]);
                        // add any numbers not in hashset to candidate values
                        for (int ii = 1; ii <= size; ii++)
                        {
                            if (!dissallowedValues.Contains(ii))
                            {
                                candidate.possibleValues.Add(ii);
                            }
                        }
                    }
                }
            }
            // pick smallest candidate
            if (candidates.Count == 0)
                return null;
            else
                return candidates.Aggregate((c1, c2) => c1.possibleValues.Count < c2.possibleValues.Count ? c1 : c2);
        }

    }
}
