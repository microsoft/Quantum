// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;


namespace Microsoft.Quantum.Samples.BitFlipCode
{
    class Program
    {
        public static void Pause()
        {
            System.Console.WriteLine("\n\nPress any key to continue...\n\n");
            System.Console.ReadKey();
        }

        static void Main(string[] args)
        {

            #region Setup

            // We begin by defining a quantum simulator to be our target
            // machine.
            var sim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true);

            #endregion

            #region Parity Check
            // In this region, we call the CheckBitFlipCodeStateParity
            // operation defined in BitFlipCode. This operation encodes
            // into a bit-flip code, such that
            //
            //     α |0〉 + β |1〉
            //
            // is encoded into
            //
            //     α |000〉 + β |111〉,
            //
            // then ensures that the parity measurements Z₀Z₁ and
            // Z₁Z₂ both return the result Zero, indicating the eigenvalue
            // (-1)⁰ is positive.

            // This check is implemented as a sequence of assertions.
            // Since we are using a target machine which supports assertions,
            // this implies that if flow control continues past the operation
            // invocation, then all of the relevant checks have passed.
            CheckBitFlipCodeStateParity.Run(sim).Wait();
            System.Console.WriteLine("Parity check passed successfully!");
            Pause();

            #endregion

            #region Correction Check
            // In this region, we call the operation
            // CheckBitFlipCodeCorrectsBitFlipErrors to check that the bit-
            // flip code actually protects against bit-flip errors.
            // As before, this operation fails if an error is not corrected
            // properly. In the UnitTesting sample, we will see how to
            // represent this pattern in terms of unit tests.

            CheckBitFlipCodeCorrectsBitFlipErrors.Run(sim).Wait();
            System.Console.WriteLine("Corrected all three bit-flip errors successfully!");
            Pause();
            #endregion

            #region Correction Check with the Canon
            // In this region, we repeat the check from above, this time using
            // operations and data types from the canon to allow us to
            // represent other codes.

            CheckCanonBitFlipCodeCorrectsBitFlipErrors.Run(sim).Wait();
            System.Console.WriteLine("Corrected all three bit-flip errors successfully!");
            Pause();
            #endregion

        }
    }
}
