// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Simulators;
using System;

namespace Microsoft.Quantum.Samples.SimpleGrover
{
    class Program
    {
        static void Main(string[] args)
        {
            var sim = new QuantumSimulator();
            var nDatabaseQubits = 5;

            var result = SearchForMarkedInput.Run(sim, nDatabaseQubits).Result;
            Console.WriteLine($"Result: {result}");

            Console.WriteLine("\n\nPress any key to continue...\n\n");
            Console.ReadKey();
        }
    }
}
