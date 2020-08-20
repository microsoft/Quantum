// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.SudokuGrover
{
    /// # Info
    /// Code to solve a Sudoku puzzle by transforming it into a graph problem 
    /// and calling the Quantum SolvePuzzle operation to solve it
    class SudokuQuantum 
    {
        /// # Summary
        /// QuantumSolve will call Q# code to solve the Sudoku puzzle and display the solution.
        /// # Input
        /// ## puzzle
        /// The Sudoku puzzle to solve.
        /// ## sim
        /// The quantum simulator.
        public static bool QuantumSolve(int[,] puzzle, QuantumSimulator sim)
        {
            int size = puzzle.GetLength(0); 
            List<ValueTuple<long, long>> emptySquareEdges;
            HashSet<ValueTuple<long, long>> startingNumberConstraints;
            List<EmptySquare> emptySquares;
            FindEdgesAndInitialNumberConstraints(puzzle, size, out emptySquareEdges, out startingNumberConstraints, out emptySquares);
            var emptySquareEdgesQArray = new QArray<ValueTuple<long, long>>(emptySquareEdges);
            var startingNumberConstraintsQArray = new QArray<ValueTuple<long, long>>(startingNumberConstraints);
            var task = SolvePuzzle.Run(sim, emptySquares.Count, size, emptySquareEdgesQArray, startingNumberConstraintsQArray);
            if (!task.Result.Item1)
                return false;
            else
            {
                var solution = task.Result.Item2.ToArray();
                for (int i = 0; i < solution.Length; i++)
                {
                    puzzle[emptySquares[i].i, emptySquares[i].j] = (int)solution[i] + 1;
                }
                Console.WriteLine("Solved puzzle.");
                return true;
            }
        }

        // An Empty square with its row and column.
        public class EmptySquare
        {
            public int i, j;
        }

        /// # Summary
        /// Find the puzzle empty square edges, and starting number constraints 
        /// for those empty squares.
        ///
        /// # Input
        /// ## puzzle
        /// The Sudoku puzzle.
        /// ## size
        /// The size of the puzzle. For example, 9 for a 9x9 puzzle.
        /// 
        /// # Output
        /// ## emptySquareEdges
        /// The list of empty square edges specifying Vertices in the same row/col/subgrid.
        /// ## startingNumberConstraints
        /// The set of numbers that this empty square can not have. 
        /// ## emptySquares
        /// list of empty squares with their i,j locations.
        static void FindEdgesAndInitialNumberConstraints(int[,] puzzle, int size, 
            out List<ValueTuple<long, long>> emptySquareEdges, out HashSet<ValueTuple<long, long>> startingNumberConstraints,
            out List<EmptySquare> emptySquares)
        {
            // find color edges ... i.e. edges between horizontal, vertical 
            // and diagonal empty squares.
            // Note that for size=4, we will subtract 1 from all puzzle
            // numbers so that they fit in 2 bits i.e. 1 to 4 becomes 0 to 3.
            int subSize = size == 9 ? 3 : 2; // subsize is 2 for size=4 and 3 for size=9
            int[,] emptyIndexes = new int[size, size];
            emptySquares = new List<EmptySquare>();
            emptySquareEdges = new List<ValueTuple<long, long>>();
            // Starting Number constraints on blank squares.
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
                        // Add all existing number constraints in 
                        // subSize x subSize to hashset of constraints for this cell.
                        // Also, add edge to any previous empty cells in the 
                        // subSize x subSize box.
                        int iSubGridStart = i / subSize * subSize;
                        int jSubGridStart = j / subSize * subSize;
                        for (int iSub = iSubGridStart; iSub < i; iSub++)
                        {
                            for (int jSub = jSubGridStart; jSub < j; jSub++)
                            {
                                if (puzzle[iSub, jSub] != 0)
                                    startingNumberConstraints.Add(
                                        ValueTuple.Create(emptyIndex, puzzle[iSub, jSub] - 1));
                                else if (iSub < i && jSub < j)
                                    emptySquareEdges.Add(
                                        ValueTuple.Create(emptyIndex, emptyIndexes[iSub, jSub]));
                            }
                        }
                        for (int ii = 0; ii < size; ii++)
                        {
                            if (puzzle[ii, j] != 0)
                                startingNumberConstraints.Add(
                                    ValueTuple.Create(emptyIndex, puzzle[ii, j] - 1));
                            else if (ii < i)
                                emptySquareEdges.Add(
                                    ValueTuple.Create(emptyIndex, emptyIndexes[ii, j]));
                        }
                        for (int jj = 0; jj < size; jj++)
                        {
                            if (puzzle[i, jj] != 0)
                                startingNumberConstraints.Add(
                                    ValueTuple.Create(emptyIndex, puzzle[i, jj] - 1));
                            else if (jj < j)
                                emptySquareEdges.Add(
                                    ValueTuple.Create(emptyIndex, emptyIndexes[i, jj]));
                        }
                    }
                }
            }
        }
    }
}
