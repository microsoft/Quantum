// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System.Diagnostics;

namespace Microsoft.Quantum.Numerics.Samples
{
    class Program
    {
        static void Main(string[] args)
        {
            var sim = new ToffoliSimulator();
            var inputs1 = new long[] { 3, 5, 3, 4, 5 };
            var inputs2 = new long[] { 5, 4, 6, 4, 1 };
            var modulus = 7;
            int numBits = 4;

            var res = CustomModAdd.Run(sim, new QArray<long>(inputs1), new QArray<long>(inputs2),
                                       modulus, numBits).Result;
            for (int i = 0; i < res.Length; ++i)
                System.Console.WriteLine($"{inputs1[i]} + {inputs2[i]} " +
                                         $"mod {modulus} = {res[i]}.");
        }
    }
}

