// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.OracleSynthesis
{
    class Program
    {
        static void Main(string[] args)
        {
            var sim = new QuantumSimulator();

            for (var func = 0; func < (1 << 8); ++func)
            {
                var res = RunOracleSynthesisOnCleanTarget.Run(sim, func, 3).Result;
                if (!res)
                {
                    Console.WriteLine($"Result = {res}");
                }
            }

            for (var func = 0; func < (1 << 8); ++func)
            {
                var res = RunOracleSynthesis.Run(sim, func, 3).Result;
                if (!res)
                {
                    Console.WriteLine($"Result = {res}");
                }
            }
        }
    }
}
