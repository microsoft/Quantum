// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.Linq;

namespace Microsoft.Quantum.Examples.Teleportation {
    class Program
    {
        static void Main(string[] args)
        {
            var sim = new QuantumSimulator();
            var rand = new Random();

            foreach (var idxRun in Enumerable.Range(0, 8)) {
                var sent = rand.Next(2) == 0;
                var received = TeleportClassicalMessage.Run(sim, sent).Result;
                Console.WriteLine($"Round {idxRun}:\tSent {sent},\tgot {received}.");
                Console.WriteLine(sent == received ? "Teleportation successful!!\n" : "\n");
            }

            Console.WriteLine("\n\nPress Enter to exit...\n\n");
            Console.ReadLine();

        }
    }
}
