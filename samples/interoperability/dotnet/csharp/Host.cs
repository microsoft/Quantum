// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static System.Diagnostics.Debug;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples
{
    static class Program
    {
        static async Task Main(string[] args)
        {
            var bits = new[] { false, true, false };
            using var sim = new QuantumSimulator();

            Console.WriteLine($"Input: {bits.ToDelimitedString()}");

            var restored = await RunAlgorithm.Run(sim, new QArray<bool>(bits));
            Console.WriteLine($"Output: {restored.ToDelimitedString()}");

            Assert(bits.Parity() == restored.Parity());
        }

        static bool Parity(this IEnumerable<bool> bitVector) =>
            bitVector.Aggregate(
                (acc, next) => acc ^ next
            );

        static string ToDelimitedString(this IEnumerable<bool> values) =>
            String.Join(", ", values.Select(x => x.ToString()));
    }
}
