// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.SudokuGrover
{
    /// <summary>
    /// Code to solve a Sudoku puzzle by transforming it into a graph problem 
    /// and calling the Quantum SolvePuzzle operation to solve it
    /// </summary>
    class SudokuQuantum 
    {
        /// <summary>
        /// QuantumSolve will call Q# code to solve the Sudoku puzzle and display the solution.
        /// </summary>
        /// <param name="puzzle">The puzzle to solve</param>
        /// <param name="sim">The QuantumSimulator to use</param>
        /// <returns>Returns true if a solution was found</returns>
        public async Task<bool> QuantumSolve(int[,] puzzle, SimulatorBase sim)
        {
            int size = puzzle.GetLength(0); 
            FindEdgesAndInitialNumberConstraints(
                puzzle, 
                size, 
                out var emptySquareEdges, 
                out var startingNumberConstraints, 
                out var emptySquares
            );
            var emptySquareEdgesQArray = new QArray<(long, long)>(emptySquareEdges);
            var startingNumberConstraintsQArray = new QArray<(long, long)>(startingNumberConstraints);
            var (foundSolution, solution) = await SolvePuzzle.Run(sim, emptySquares.Count, size, emptySquareEdgesQArray, startingNumberConstraintsQArray);
            if (foundSolution)
            {
                foreach (var (emptySquare, completion) in Enumerable.Zip(emptySquares, solution))
                {
                    puzzle[emptySquare.Row, emptySquare.Column] = (int)completion + 1;
                }
                Console.WriteLine("Solved puzzle.");
            }
            return foundSolution;
        }

        /// <summary>
        /// An Empty square with its row and column. 
        /// </summary>
        struct EmptySquare
        {
            public int Row;
            public int Column;
        }

        /// <summary>
        /// Find the puzzle empty square edges, and starting number constraints 
        /// for those empty squares.
        /// </summary>
        /// <param name="puzzle">The Sudoku puzzle</param>
        /// <param name="size">The size of the puzzle. For example, 9 for a 9x9 puzzle</param>
        /// <param name="emptySquareEdges">The list of empty square edges specifying Vertices in the same row/col/subgrid</param>
        /// <param name="startingNumberConstraints">The set of numbers that this empty square can not have</param>
        /// <param name="emptySquares">List of empty squares with their i,j locations</param>
        void FindEdgesAndInitialNumberConstraints(int[,] puzzle, int size, 
            out List<(long, long)> emptySquareEdges, out HashSet<(long, long)> startingNumberConstraints,
            out List<EmptySquare> emptySquares)
        {
            // find color edges ... i.e. edges between horizontal, vertical 
            // and diagonal empty squares.
            // Note that for size=4, we will subtract 1 from all puzzle
            // numbers so that they fit in 2 bits i.e. 1 to 4 becomes 0 to 3.
            int subSize = size == 9 ? 3 : 2; // subsize is 2 for size=4 and 3 for size=9
            var emptyIndexes = new int[size, size];
            emptySquares = new List<EmptySquare>();
            emptySquareEdges = new List<(long, long)>();
            // Starting Number constraints on blank squares.
            startingNumberConstraints = new HashSet<(long, long)>();

            for (int i = 0; i < size; i++)
            {
                for (int j = 0; j < size; j++)
                {
                    if (puzzle[i, j] == 0)
                    {
                        var emptyIndex = emptySquares.Count;
                        emptyIndexes[i, j] = emptyIndex;
                        emptySquares.Add(new EmptySquare
                        {
                            Row = i,
                            Column = j
                        });
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
                                        (emptyIndex, puzzle[iSub, jSub] - 1));
                                else if (iSub < i && jSub < j)
                                    emptySquareEdges.Add(
                                        (emptyIndex, emptyIndexes[iSub, jSub]));
                            }
                        }
                        for (int ii = 0; ii < size; ii++)
                        {
                            if (puzzle[ii, j] != 0)
                                startingNumberConstraints.Add(
                                    (emptyIndex, puzzle[ii, j] - 1));
                            else if (ii < i)
                                emptySquareEdges.Add(
                                    (emptyIndex, emptyIndexes[ii, j]));
                        }
                        for (int jj = 0; jj < size; jj++)
                        {
                            if (puzzle[i, jj] != 0)
                                startingNumberConstraints.Add(
                                    (emptyIndex, puzzle[i, jj] - 1));
                            else if (jj < j)
                                emptySquareEdges.Add(
                                    (emptyIndex, emptyIndexes[i, jj]));
                        }
                    }
                }
            }
        }
    }
}
