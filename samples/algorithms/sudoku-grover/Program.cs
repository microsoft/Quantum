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
    class Program
    {
        /// <summary>
        /// Main entry point.
        /// </summary>
        /// <param name="args">
        /// <para>Add the following argument to specify which puzzles to run:</para>
        /// <list type="bullet">
        /// <item><description>`all` or blank : run all puzzles (default)</description></item>
        /// <item><description>`4x4-classic` : test classic algorthm on a 4x4 puzzle</description></item>
        /// <item><description>`4x4-1` : test Quantum solution of 4x4 puzzle missing 1 number</description></item>
        /// <item><description>`4x4-3` : test Quantum solution of 4x4 puzzle missing 3 numbers</description></item>
        /// <item><description>`4x4-4` : test Quantum solution of 4x4 puzzle missing 4 numbers</description></item>
        /// <item><description>`9x9-1` : test classic algorithm and Quantum solution on a 9x9 puzzle with 1 missing number</description></item>
        /// <item><description>`9x9-2` : test Quantum solution on a 9x9 puzzle with 2 missing numbers</description></item>
        /// <item><description>`9x9-64` : test Quantum solution on a 9x9 puzzle with 64 missing numbers</description></item>
        /// </list>
        /// </param>
        static void Main(string[] args)
        {
            var puzzleToRun = args.Length > 0 ? args[0] : "all";

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

            SudokuClassic sudokuClassic = new SudokuClassic();
            SudokuQuantum sudokuQuantum = new SudokuQuantum();

            if (puzzleToRun == "4x4-classic" || puzzleToRun == "all") 
            {
                // Test solving a 4x4 Sudoku puzzle using classical computing.
                // Missing numbers are denoted by 0.
                int[,] puzzle4 = {
                    { 0,2,0,4 },
                    { 3,0,0,2 },
                    { 0,0,4,1 },
                    { 4,0,2,0 } };
                Console.WriteLine("Solving 4x4 using classical computing.");
                ShowGrid(puzzle4);
                bool resultFound = sudokuClassic.SolveSudokuClassic(puzzle4);
                VerifyAndShowResult(resultFound, puzzle4, answer4);
            }
            if (puzzleToRun == "4x4-1" || puzzleToRun == "all") 
            {
                // Testing solving an easy 4x4 puzzle with only 1 missing number with Quantum.
                int[,] puzzle4_1 = {
                    { 0,2,3,4 },
                    { 3,4,1,2 },
                    { 2,3,4,1 },
                    { 4,1,2,3 } };
                Console.WriteLine("Quantum Solving 4x4 with 1 missing number.");
                ShowGrid(puzzle4_1);
                bool resultFound = sudokuQuantum.QuantumSolve(puzzle4_1, sim).Result;
                VerifyAndShowResult(resultFound, puzzle4_1, answer4);
            }
            if (puzzleToRun == "4x4-3" || puzzleToRun == "all") 
            {
                // Test 4x4 puzzle with 3 missing numbers with Quantum.
                int[,] puzzle4_3 = {
                    { 0,2,3,4 },
                    { 3,0,1,2 },
                    { 2,3,4,1 },
                    { 4,0,2,3 } };
                Console.WriteLine("Quantum Solving 4x4 with 3 missing numbers.");
                ShowGrid(puzzle4_3);
                bool resultFound = sudokuQuantum.QuantumSolve(puzzle4_3, sim).Result;
                VerifyAndShowResult(resultFound, puzzle4_3, answer4);
            }
            if (puzzleToRun == "4x4-4" || puzzleToRun == "all") 
            {
                // Test 4x4 puzzle with 4 missing numbers with Quantum.
                int[,] puzzle4_4 = {
                    { 0,0,3,4 },
                    { 0,0,1,2 },
                    { 2,3,4,1 },
                    { 4,1,2,3 } };
                Console.WriteLine("Quantum Solving 4x4 with 4 missing numbers.");
                ShowGrid(puzzle4_4);
                bool resultFound = sudokuQuantum.QuantumSolve(puzzle4_4, sim).Result;
                VerifyAndShowResult(resultFound, puzzle4_4, answer4);
            }
            if (puzzleToRun == "9x9-1" || puzzleToRun == "all") 
            {
                // Test 9x9 puzzle with classical and quantum - 1 missing number.
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
                int[,] puzzle9_1_copy = CopyIntArray(puzzle9_1);

                Console.WriteLine("Solving 9x9 with 1 missing number using classical computing.");
                ShowGrid(puzzle9_1);
                bool resultFound = sudokuClassic.SolveSudokuClassic(puzzle9_1);
                VerifyAndShowResult(resultFound, puzzle9_1, answer9);

                Console.WriteLine("Solving 9x9 with 1 missing number using Quantum Computing.");
                ShowGrid(puzzle9_1_copy);
                resultFound = sudokuQuantum.QuantumSolve(puzzle9_1_copy, sim).Result;
                VerifyAndShowResult(resultFound, puzzle9_1_copy, answer9);
            }
            if (puzzleToRun == "9x9-2" || puzzleToRun == "all") 
            {
                // Test 9x9 puzzle with quantum - 2 missing numbers.
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
                Console.WriteLine("Solving 9x9 with 2 missing numbers using Quantum Computing.");
                ShowGrid(puzzle9_2);
                bool resultFound = sudokuQuantum.QuantumSolve(puzzle9_2, sim).Result;
                VerifyAndShowResult(resultFound, puzzle9_2, answer9);
            }
            if (puzzleToRun == "9x9-64" || puzzleToRun == "all") 
            {
                // Test hard 9x9 puzzle with classical and quantum.
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
                int[,] puzzle9_copy = CopyIntArray(puzzle9);

                Console.WriteLine("Solving 9x9 with 64 missing numbers using classical computing.");
                ShowGrid(puzzle9);
                bool resultFound = sudokuClassic.SolveSudokuClassic(puzzle9);
                VerifyAndShowResult(resultFound, puzzle9, answer9);

                Console.WriteLine("Solving 9x9 with 64 missing numbers using Quantum Computing. Cntrl-C to stop.");
                ShowGrid(puzzle9_copy);
                resultFound = sudokuQuantum.QuantumSolve(puzzle9_copy, sim).Result;
                VerifyAndShowResult(resultFound, puzzle9_copy, answer9);
            }
            Console.WriteLine("Finished.");
        }

        /// <summary>
        /// If result was found, verify it is correct (matches the answer) and show it
        /// </summary>
        /// <param name="resultFound">True if a result was found for the puzzle</param>
        /// <param name="puzzle">The puzzle to verify</param>
        /// <param name="answer">The correct puzzle result</param>
        static void VerifyAndShowResult(bool resultFound, int[,] puzzle, int[,] answer) 
        {
            if (!resultFound) 
                Console.WriteLine("No solution found.");
            else 
            {
                bool good = puzzle.Cast<int>().SequenceEqual(answer.Cast<int>());
                if (good)
                    Console.WriteLine("Result verified correct.");
                ShowGrid(puzzle);
            }
            Pause();
        }

        /// <summary>
        /// Copy an Int 2 dimensional array
        /// </summary>
        /// <param name="org">The array to copy</param>
        /// <returns>A copy of the array</returns>
        static int[,] CopyIntArray(int[,] org)
        {
            int size = org.GetLength(0);
            int[,] result = new int[size, size];
            for (int i = 0; i < size; i++)
                for (int j = 0; j < size; j++)
                    result[i, j] = org[i, j];
            return result;
        }
 
        /// <summary>
        /// Display the puzzle
        /// </summary>
        static void ShowGrid(int[,] puzzle)
        {
            int size = puzzle.GetLength(0);
            for (int i = 0; i < size; i++)
            {
                Console.WriteLine(new String('-', 4 * size + 1));
                for (int j = 0; j < size; j++)
                {
                    if (puzzle[i, j] == 0)
                        Console.Write("|   ");
                    else
                        Console.Write($"| {puzzle[i, j], 1} ");
                }
                Console.WriteLine("|");
            }
            Console.WriteLine(new String('-', 4 * size + 1));
        }

        /// <summary>
        /// Pause execution with a message and wait for a key to be pressed to continue.
        /// </summary>
        static void Pause()
        {
            System.Console.WriteLine("\n\nPress any key to continue...\n\n");
            System.Console.ReadKey();
        }

    }
}
