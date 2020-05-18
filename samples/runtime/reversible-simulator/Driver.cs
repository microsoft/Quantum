// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Samples
{
    class Driver {
        public static async Task Main(string[] args) {
            var sim = new ReversibleSimulator();
            var bits = new[] {false, true};

            foreach (var a in bits) {
                foreach (var b in bits) {
                    foreach (var c in bits) {
                        var f = await RunMajority.Run(sim, a, b, c);
                        Console.WriteLine($"Majority({a,5}, {b,5}, {c,5})  =  {f,5}");
                    }
                }
            }
        }
    }
}
