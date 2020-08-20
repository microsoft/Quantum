// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Samples.SudokuGrover
{

    /// # Info
    /// Classical code to solve a Sudoku puzzle
    class SudokuClassic 
    {
        /// # Summary
        /// Classical Sudoku solution using Recursive Depth First Search.
        /// ## puzzle
        /// The Sudoku puzzle.
        public static bool SolveSudukoClassic(int[,] puzzle)
        {
            int size = puzzle.GetLength(0);
            int subSize = size == 9 ? 3 : 2; // subsize is 2 for size=4 and 3 for size=9
            // find empty cell will least possible options and try each.
            Candidate emptyCell = BestSquare(puzzle, size, subSize);
            if (emptyCell == null)
                return true; // no more empty cells --- success!!
            if (emptyCell.possibleValues.Count == 0)
                return false; // there's an empty cell, but no possible values -- dead end.
            foreach (int possibleValue in emptyCell.possibleValues)
            {
                puzzle[emptyCell.i, emptyCell.j] = possibleValue;
                bool result = SolveSudukoClassic(puzzle);
                if (result)
                    return true;
            }
            // we tried all values and none worked  -- dead end.
            puzzle[emptyCell.i, emptyCell.j] = 0;
            return false;
        }

        /// # Summary
        /// For classical Sudoku, Candidate is an empty square and 
        /// the possible values it can take.
        class Candidate
        {
            public int i;
            public int j;
            public List<int> possibleValues = new List<int>();
        }

        /// # Summary
        /// For classical Sudoku, go thru entire puzzle and find all
        /// empty squares and, for each, the possible numbers for that square.
        /// 
        /// # Input
        /// ## puzzle
        /// The Sudoku puzzle.
        /// ## size
        /// The size of the puzzle i.e. 4 or 9.
        /// ## subSize
        /// The size of the subGrids i.e. if size = 9, subSize = 3.
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
                        // add all numbers in subSize x subSize to hashset.
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
                        // add all numbers in this row to hashset.
                        for (int ii = 0; ii < size; ii++)
                            if (puzzle[ii, j] != 0)
                                dissallowedValues.Add(puzzle[ii, j]);
                        // add all numbers in this col to hashset.
                        for (int jj = 0; jj < size; jj++)
                            if (puzzle[i, jj] != 0)
                                dissallowedValues.Add(puzzle[i, jj]);
                        // add any numbers not in hashset to candidate values.
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
            // pick smallest candidate.
            if (candidates.Count == 0)
                return null;
            else
                return candidates.Aggregate((c1, c2) => c1.possibleValues.Count < c2.possibleValues.Count ? c1 : c2);
        }
    }
}