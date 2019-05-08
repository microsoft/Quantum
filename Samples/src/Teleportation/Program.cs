// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Simulators;
using System.Linq;

namespace Microsoft.Quantum.Samples.Teleportation {
    class Program
    {
        static void Main(string[] args)
        {
            using (var sim = new QuantumSimulator())
            {
                var rand = new System.Random();

                foreach (var idxRun in Enumerable.Range(0, 8))
                {
                    var sent = rand.Next(2) == 0;
                    var received = TeleportClassicalMessage.Run(sim, sent).Result;
                    System.Console.WriteLine($"Round {idxRun}:\tSent {sent},\tgot {received}.");
                    System.Console.WriteLine(sent == received ? "Teleportation successful!!\n" : "\n");
                }
            }
        }
    }
}
