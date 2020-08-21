// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Samples.SudokuGrover
{
    /// <summary>
    /// Classical code to solve a Sudoku puzzle
    /// </summary>
    class SudokuClassic 
    {
        /// <summary>
        /// Classical Sudoku solution using Recursive Depth First Search.
        /// </summary>
        /// <param name="puzzle">he Sudoku puzzle to solve.</param>
        /// <returns>Returns true if solution found</returns>
        public bool SolveSudokuClassic(int[,] puzzle)
        {
            int size = puzzle.GetLength(0);
            int subSize = size == 9 ? 3 : 2; // subsize is 2 for size=4 and 3 for size=9
            // find empty cell will least possible options and try each.
            var emptyCell = BestSquare(puzzle, size, subSize);
            if (emptyCell == NoCandidate)
                return true; // no more empty cells --- success!!
            if (emptyCell.possibleValues.Count == 0)
                return false; // there's an empty cell, but no possible values -- dead end.
            foreach (int possibleValue in emptyCell.possibleValues)
            {
                puzzle[emptyCell.Row, emptyCell.Column] = possibleValue;
                if (SolveSudokuClassic(puzzle)) return true;
            }
            // we tried all values and none worked  -- dead end.
            puzzle[emptyCell.Row, emptyCell.Column] = 0;
            return false;
        }

        /// <summary>
        /// For classical Sudoku, Candidate is an empty square and 
        /// the possible values it can take.
        /// </summary>
        class Candidate
        {
            public int Row;
            public int Column;
            public List<int> possibleValues = new List<int>();
        }

        /// <summary>
        /// If no Candidate can be found, use this object
        /// </summary>
        /// <returns></returns>
        Candidate NoCandidate = new Candidate();

        /// <summary>
        /// For classical Sudoku, go thru entire puzzle and find all
        /// empty squares and, for each, the possible numbers for that square.
        /// </summary>
        /// <param name="puzzle">The Sudoku puzzle to solve</param>
        /// <param name="size">The size of the puzzle i.e. 4 or 9.</param>
        /// <param name="subSize">The size of the subGrids i.e. if size = 9, subSize = 3</param>
        /// <returns>Returns the best candidate square which is the square 
        /// with the fewest number of possible values.
        /// If there are no empty squares, it returns NoCandidate</returns>
        Candidate BestSquare(int[,] puzzle, int size, int subSize)
        {
            List<Candidate> candidates = new List<Candidate>();
            for (int i = 0; i < size; i++)
            {
                for (int j = 0; j < size; j++)
                {
                    if (puzzle[i, j] == 0)
                    {
                        Candidate candidate = new Candidate {
                            Row = i,
                            Column = j
                        };
                        candidates.Add(candidate);
                        var disallowedValues = new HashSet<int>();
                        // add all numbers in subSize x subSize to hashset.
                        int iSubGridStart = i / subSize * subSize;
                        int jSubGridStart = j / subSize * subSize;
                        for (int iSub = iSubGridStart; iSub < iSubGridStart + subSize; iSub++)
                        {
                            for (int jSub = jSubGridStart; jSub < jSubGridStart + subSize; jSub++)
                            {
                                if (puzzle[iSub, jSub] != 0)
                                    disallowedValues.Add(
                                        puzzle[iSub, jSub]);
                            }
                        }
                        // add all numbers in this row to hashset.
                        for (int ii = 0; ii < size; ii++)
                        {
                            if (puzzle[ii, j] != 0)
                                disallowedValues.Add(puzzle[ii, j]);
                        }
                        // add all numbers in this col to hashset.
                        for (int jj = 0; jj < size; jj++)
                        {
                            if (puzzle[i, jj] != 0)
                                disallowedValues.Add(puzzle[i, jj]);
                        }
                        // add any numbers not in hashset to candidate values.
                        for (int ii = 1; ii <= size; ii++)
                        {
                            if (!disallowedValues.Contains(ii))
                            {
                                candidate.possibleValues.Add(ii);
                            }
                        }
                    }
                }
            }
            // pick smallest candidate.
            return candidates.Count == 0
                ? NoCandidate
                : candidates.Aggregate((c1, c2) => c1.possibleValues.Count < c2.possibleValues.Count ? c1 : c2);
        }
    }
}