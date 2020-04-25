// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Samples.OrderFinding
{
    /// <summary>
    /// This class holds a permutation π and allows to compute its
    /// order in various different ways (exactly, classical guess, 
    /// and quantum guess)
    /// </summary>
    class Permutation
    {
        /// <summary>
        /// The permutation object is constructed with a permutation π and
        /// a number of shots for repetitions when guessing.
        /// <param name="permutation">Permutation π over 4 elements 0, 1, 2, 3</param>
        /// <param name="shots">Number of repetitions when guessing</param>
        /// </summary>
        public Permutation(List<int> permutation, int shots = 1024)
        {
            _p = permutation;
            _shots = shots;
        }

        /// <summary>
        /// Returns the exact order (length) of the cycle that contains a given index
        /// <summary>
        public int ComputeOrder(int index)
        {
            int order = 1, cur = index;
            while (index != _p[cur])
            {
                ++order;
                cur = _p[cur];
            }
            return order;
        }

        /// <summary>
        /// Guesses the order (classically) for cycle that contains a given index
        ///
        /// The algorithm computes π³(index).  If the result is index, it
        /// returns 1 or 3 with probability 50% each, otherwise, it
        /// returns 2 or 4 with probability 50% each. 
        /// <summary>
        private int GuessOrderClassicalOne(int index)
        {
            if (_p[_p[_p[index]]] == index)
            {
                return _rnd.Next(2) == 0 ? 1 : 3;
            }
            else
            {
                return _rnd.Next(2) == 0 ? 2 : 4;
            }
        }

        /// <summary>
        /// Guesses the order classically by applying estimate `shots` many times and returning the percentage for each order that was returned.
        /// </summary>
        public IEnumerable<(int order, double percentage)> GuessOrderClassical(int index)
        {
            return Enumerable.Range(0, _shots).Select(_ => GuessOrderClassicalOne(index)).GroupBy(n => n, (n, list) => (n, list.Count() / (double)_shots));
        }

        /// <summary>
        /// The quantum estimation calls the quantum algorithm in the Q# file which computes the permutation
        /// πⁱ(input) where i is a superposition of all values from 0 to 7.  The algorithm then uses QFT to
        /// find a period in the resulting state.  The result needs to be post-processed to find the estimate.
        /// <summary>
        private int GuessOrderQuantumOne(int index)
        {
            var result = FindOrder.Run(_sim, new QArray<long>(_p.ConvertAll(x => (long)x)), (long)index).Result;

            if (result == 0)
            {
                var guess = _rnd.NextDouble();
                // the probability distribution is extracted from the second
                // column (m = 0) in Fig. 2's table on the right-hand side,
                // in the original and referenced paper.
                if (guess <= 0.5505)
                {
                    return 1;
                }
                else if (guess <= 0.5505 + 0.1009)
                {
                    return 2;
                }
                else if (guess <= 0.5505 + 0.1009 + 0.1468)
                {
                    return 3;
                }
                else
                {
                    return 4;
                }
            }
            else if (result % 2 == 1)
            {
                return 3;
            }
            else if (result == 2 || result == 6)
            {
                return 4;
            }
            else /* result == 4 */
            {
                return 2;
            }
        }

        /// <summary>
        /// Guesses order using Q# for shots times, and returns the percentage for each order that was returned.
        /// </summary>
        public IEnumerable<(int order, double percentage)> GuessOrderQuantum(int index)
        {
            return Enumerable.Range(0, _shots).Select(_ => GuessOrderQuantumOne(index)).GroupBy(n => n, (n, list) => (n, list.Count() / (double)_shots));
        }

        public override string ToString() => "[" + String.Join(" ", _p) + "]";

        private readonly List<int> _p;
        private readonly int _shots;
        private readonly Random _rnd = new Random();
        private readonly QuantumSimulator _sim = new QuantumSimulator();
    }

    class Program
    {
        static void Main(string[] args)
        {
            /* user input (permutation must have 4 elements) */
            var perm = new Permutation(new List<int> { 1, 2, 3, 0 });
            int index = 0;

            /* print some info on the permutation */
            Console.WriteLine($"Permutation: {perm}");
            Console.WriteLine($"Find cycle length at index {index}\n");

            /* compute exact order */
            Console.WriteLine($"Exact order: {perm.ComputeOrder(index)}\n");

            /* guess order classically */
            Console.WriteLine("Guess classically:");
            Console.WriteLine(String.Join("\n", perm.GuessOrderClassical(index).Select(x => $"{x.order}: {x.percentage.ToString("P")}")));

            /* guess order with Q# */
            Console.WriteLine("\nGuess with Q#:");
            Console.WriteLine(String.Join("\n", perm.GuessOrderQuantum(index).Select(x => $"{x.order}: {x.percentage.ToString("P")}")));

            Console.WriteLine("\nPress Enter to continue...");
            Console.ReadLine();
        }
    }
}
