using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.SudokuGrover
{
    class Program
    {
        static void Main(string[] args)
        {
            var sim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true);

            // missing numbers are denoted by 0
            int[,] puzzle4 = {
                { 0,2,0,4 },
                { 3,0,0,2 },
                { 0,0,4,1 },
                { 4,0,2,0 } };
            int[,] answer4 = {
                { 1,2,3,4 },
                { 3,4,1,2 },
                { 2,3,4,1 },
                { 4,1,2,3 } };
            Console.WriteLine("Solving 4x4 using classical computing");
            int size = 4;
            showGrid(puzzle4, size);
            solve_suduko_classic(puzzle4, 4, 2);
            bool good = puzzle4.Cast<int>().SequenceEqual(answer4.Cast<int>());
            if (good)
                Console.WriteLine("result verified correct");
            showGrid(puzzle4, size);
            Pause();


            // var emptySquareEdges = new QArray<ValueTuple<long, long>>();
            // // Starting Number constraints on blank squares
            // var startingNumberConstraints = new QArray<ValueTuple<long, long>>(ValueTuple.Create(0, 1), ValueTuple.Create(0, 2), ValueTuple.Create(0, 3));
            // int V = 1;    // 1 empty square 
            // var task = SolvePuzzle.Run(sim, V, 2, emptySquareEdges, startingNumberConstraints);
            // Pause();

            Console.WriteLine("Quantum Solving 4x4 with 1 missing number");
            int[,] puzzle4_1 = {
                { 0,2,3,4 },
                { 3,4,1,2 },
                { 2,3,4,1 },
                { 4,1,2,3 } };
            quantumSolve(puzzle4_1, 4, 2, sim);
            good = puzzle4_1.Cast<int>().SequenceEqual(answer4.Cast<int>());
            if (good)
                Console.WriteLine("quantum result verified correct");
            Pause();

            Console.WriteLine("Quantum Solving 4x4 with 3 missing numbers");
            int[,] puzzle4_3 = {
                { 0,2,3,4 },
                { 3,0,1,2 },
                { 2,3,4,1 },
                { 4,0,2,3 } };
            quantumSolve(puzzle4_3, 4, 2, sim);
            good = puzzle4_3.Cast<int>().SequenceEqual(answer4.Cast<int>());
            if (good)
                Console.WriteLine("quantum result verified correct");
            Pause();

            Console.WriteLine("Quantum Solving 4x4 with 4 missing numbers");
            int[,] puzzle4_4 = {
                { 0,0,3,4 },
                { 0,0,1,2 },
                { 2,3,4,1 },
                { 4,1,2,3 } };
            quantumSolve(puzzle4_4, 4, 2, sim);
            good = puzzle4_4.Cast<int>().SequenceEqual(answer4.Cast<int>());
            if (good)
                Console.WriteLine("quantum result verified correct");
            Pause();

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
            var puzzle9_1_copy = copyArray(puzzle9_1, 9);
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
            Console.WriteLine("Solving 9x9 with 1 missing number using classical computing");
            showGrid(puzzle9_1, 9);
            solve_suduko_classic(puzzle9_1, 9, 3);
            good = puzzle9_1.Cast<int>().SequenceEqual(answer9.Cast<int>());
            if (!good)
                Console.WriteLine("classical test failed");
            else
            {
                Console.WriteLine("classical test passed");
                showGrid(puzzle9_1, 9);
            }
            Pause();
            Console.WriteLine("Solving 9x9 with 1 missing number using Quantum Computing");
            quantumSolve(puzzle9_1_copy, 9, 3, sim);
            good = puzzle9_1_copy.Cast<int>().SequenceEqual(answer9.Cast<int>());
            if (good)
                Console.WriteLine("quantum result verified correct");
            Pause();

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
            var puzzle9_2_copy = copyArray(puzzle9_2, 9);
            Console.WriteLine("Solving 9x9 with 2 missing numbers using Quantum Computing");
            quantumSolve(puzzle9_2_copy, 9, 3, sim);
            good = puzzle9_2_copy.Cast<int>().SequenceEqual(answer9.Cast<int>());
            if (good)
                Console.WriteLine("quantum result verified correct");
            Pause();            


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
            var puzzle9_copy = copyArray(puzzle9, 9);
            Console.WriteLine("Solving 9x9 with lots of missing number using classical computing");
            showGrid(puzzle9, 9);
            solve_suduko_classic(puzzle9, 9, 3);
            good = puzzle9.Cast<int>().SequenceEqual(answer9.Cast<int>());
            if (!good)
                Console.WriteLine("classical test failed");
            else
            {
                Console.WriteLine("classical test passed");
                showGrid(puzzle9, 9);
            }
            Pause();

            Console.WriteLine("Solving 9x9 with lots of missing number using Quantum Computing - uncomment to test this");
            // this would be fun
            // quantumSolve(puzzle9_copy, 9, 3, sim);
            Pause();
            Console.WriteLine("finished");

        }

        public class EmptySquare
        {
            public int i, j;
        }

        public static int[,] copyArray(int[,] org, int size)
        {
            int[,] result = new int[size, size];
            for (int i = 0; i < size; i++)
                for (int j = 0; j < size; j++)
                    result[i, j] = org[i, j];
            return result;
        }
 
        // size of the puzzle is either 4 (for 4x4) or 9 (for 9x9)
        public static void quantumSolve(int[,] puzzle, int size, int subSize, QuantumSimulator sim)
        {
            List<ValueTuple<long, long>> emptySquareEdges;
            HashSet<ValueTuple<long, long>> startingNumberConstraints;
            List<EmptySquare> emptySquares;
            findEdgesAndInitialNumberConstraints(puzzle, size, subSize, out emptySquareEdges, out startingNumberConstraints, out emptySquares);
            // if 4x4 puzzle, numbers 0-3 can be encoded with 2 bits. Otherwise, use 4 bits for encoding numbers 0-8 in a 9x9 puzzle
            int bitsPerColor = size == 4 ? 2 : 4;
            // add dissallowed numbers for each vertex. e.g. for size=9x9, no numbers above 8 are allowed 
            for(int i = 0; i < emptySquares.Count; i++) {
                for (int dissallowedColor = size; dissallowedColor< System.Math.Round(System.Math.Pow(2,bitsPerColor)); dissallowedColor++)
                    startingNumberConstraints.Add(ValueTuple.Create(i,dissallowedColor));
            }
            var emptySquareEdgesQArray = new QArray<ValueTuple<long, long>>(emptySquareEdges);
            var startingNumberConstraintsQArray = new QArray<ValueTuple<long, long>>(startingNumberConstraints);
            Console.WriteLine("Quantum solving puzzle ");
            showGrid(puzzle, size);
            var task = SolvePuzzle.Run(sim, emptySquares.Count, bitsPerColor, size, emptySquareEdgesQArray, startingNumberConstraintsQArray);
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
                showGrid(puzzle, size);
            }
        }

        public static void showGrid(int[,] puzzle, int size)
        {
            for (int i = 0; i < size; i++)
            {
                Console.Write("-");
                for (int j = 0; j < size; j++)
                    Console.Write("----");
                Console.WriteLine("");
                Console.Write("|");
                for (int j = 0; j < size; j++) 
                {
                    if (puzzle[i,j]==0)
                        Console.Write("   |");
                    else
                        Console.Write(String.Format(" {0,1} |", puzzle[i, j]));
                }
                Console.WriteLine("");
            }
            Console.Write("-");
            for (int j = 0; j < size; j++)
                    Console.Write("----");
            Console.WriteLine("");
        }

        public static void findEdgesAndInitialNumberConstraints(int[,] puzzle, int size, int subSize,
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
                        EmptySquare es = new EmptySquare();
                        es.i = i;
                        es.j = j;
                        emptySquares.Add(es);
                        // add all existing number constraints in subSize x subSize to hashset of constraints for this cell
                        // Also, add edge to any previous empty cells in the subSize x subSize box
                        int i3 = i / subSize * subSize;
                        int j3 = j / subSize * subSize;
                        for (int ii = i3; ii < i; ii++)
                        {
                            for (int jj = j3; jj < j; jj++)
                            {
                                if (puzzle[ii, jj] != 0)
                                    startingNumberConstraints.Add(ValueTuple.Create(emptyIndex, puzzle[ii, jj] - 1));
                                else if (ii < i && jj < j)
                                    emptySquareEdges.Add(ValueTuple.Create(emptyIndex, emptyIndexes[ii, jj]));
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

        public static void Pause()
        {
            System.Console.WriteLine("\n\nPress any key to continue...\n\n");
            System.Console.ReadKey();
        }
        static bool solve_suduko_classic(int[,] puzzle, int size, int subSize)
        {
            // find empty cell will least possible options and try each
            Candidate c = best_square(puzzle, size, subSize);
            if (c == null)
                return true; // no more empty cells --- success!!
            if (c.values.Count == 0)
                return false; // there's an empty cell, but no possible values -- dead end
            foreach (int v in c.values)
            {
                puzzle[c.i, c.j] = v;
                bool result = solve_suduko_classic(puzzle, size, subSize);
                if (result)
                    return true;
            }
            // we tried all values and none worked  -- dead end
            puzzle[c.i, c.j] = 0;
            return false;
        }
        class Candidate
        {
            public int i;
            public int j;
            public List<int> values = new List<int>();
        }
        static Candidate best_square(int[,] puzzle, int size, int subSize)
        {
            // go thru entire puzzle and find all empty squares and, for each, number of possible numbers for that square
            List<Candidate> candidates = new List<Candidate>();
            for (int i = 0; i < size; i++)
            {
                for (int j = 0; j < size; j++)
                {
                    if (puzzle[i, j] == 0)
                    {
                        Candidate c = new Candidate();
                        c.i = i;
                        c.j = j;
                        candidates.Add(c);
                        HashSet<int> h = new HashSet<int>();
                        // add all numbers in subSize x subSize to hashset
                        int i3 = i / subSize * subSize;
                        int j3 = j / subSize * subSize;
                        for (int ii = 0; ii < subSize; ii++)
                        {
                            for (int jj = 0; jj < subSize; jj++)
                            {
                                if (puzzle[i3 + ii, j3 + jj] != 0)
                                    h.Add(puzzle[i3 + ii, j3 + jj]);
                            }
                        }
                        // add all numbers in this row to hashset
                        for (int ii = 0; ii < size; ii++)
                            if (puzzle[ii, j] != 0)
                                h.Add(puzzle[ii, j]);
                        // add all numbers in this col to hashset
                        for (int jj = 0; jj < size; jj++)
                            if (puzzle[i, jj] != 0)
                                h.Add(puzzle[i, jj]);
                        // add any numbers not in hashset to candidate values
                        for (int ii = 1; ii <= size; ii++)
                        {
                            if (!h.Contains(ii))
                            {
                                c.values.Add(ii);
                            }
                        }
                    }
                }
            }
            // pick smallest candidate
            if (candidates.Count == 0)
                return null;
            else
                return candidates.Aggregate((c1, c2) => c1.values.Count < c2.values.Count ? c1 : c2);
        }

    }
}

