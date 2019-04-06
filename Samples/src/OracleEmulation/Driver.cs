// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Emulation;

namespace Microsoft.Quantum.Samples.OracleEmulation
{
    class Driver
    {
        public static void Pause()
        {
            System.Console.WriteLine("\n\nPress any key to continue...\n\n");
            System.Console.ReadKey();
        }

        static void Main(string[] args)
        {
            // We begin by defining a quantum emulator (defined in Emulator.cs)
            // to be our target machine.
            using (var qsim = new QuantumEmulator())
            {
                #region Simple oracles

                // Create an oracle from a C# lambda.
                // The result is an operation with signature
                //   (Qubit[], Qubit[]) => Unit
                // that can be passed to Q#.
                var oracle = PermutationOracle.Create(qsim, (x, y) => 42 ^ y);

                // Provide the definition of an oracle that has been declared in
                // Q# as `intrinsic`. This way, the `HalfAnswer` oracle is
                // accessible via the `OracleEmulation` namespace and does not
                // have to be passed to operations depending on it (unlike the
                // oracle created above).
                PermutationOracle.Register<HalfAnswer>(qsim, (x, y) => 21 ^ y);

                // Execute the simple oracles and print the results.
                RunConstantOracles.Run(qsim, oracle).Wait();
                Pause();

                #endregion

                #region Emulated arithmetic

                // Run the demo for emulated arithmetic.
                RunAddOracle.Run(qsim).Wait();
                Pause();

                #endregion
            }
        }
    }
}