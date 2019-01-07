// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Samples.Measurement
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

            #region Measuring One Qubit
            // In this region, we call the MeasurementOneQubit operation
            // from Measurement.qs, which prepares a qubit in the |+〉 ≔ H|0〉
            // state and asserts that the probability of observing a Zero
            // result is 50%.

            // Thus, we will run the operation several times and report
            // the mean.

            var averageResult = Enumerable.Range(0, 100).Select((idx) =>
                MeasurementOneQubit.Run(sim).Result == Simulation.Core.Result.One ? 1 : 0
            ).Average();
            System.Console.WriteLine($"Frequency of 〈0| given H|0〉: {averageResult}");

            Pause();
            #endregion

            #region Measuring Two Qubits
            // Next, we generalize to consider measuring two qubits, each
            // in the Z-basis. The MeasurementTwoQubits operation
            // returns a (Result, Result), one for each qubit; let's print
            // out a few such measurements.

            foreach (var idxMeasurement in Enumerable.Range(0, 8))
            {
                var results = MeasurementTwoQubits.Run(sim).Result;
                System.Console.WriteLine($"Measured HH|00〉 and observed {results}.");
            }

            Pause();
            #endregion

            #region Measuring in the Bell Basis
            // Finally, we demonstrate that if we measure each half of
            // the entangled pair CNOT₀₁ · H |00〉 = (|00〉 + |11〉) / sqrt(2),
            // the parity of the observed results is always positive. That is,
            // unlike in the previous example, the two Result values are
            // always the same.

            foreach (var idxMeasurement in Enumerable.Range(0, 8))
            {
                var results = MeasurementBellBasis.Run(sim).Result;
                System.Console.WriteLine($"Measured CNOT₀₁ · H |00〉 and observed {results}.");
            }

            #endregion

            System.Console.WriteLine("\n\nPress Enter to continue...\n\n");
            System.Console.ReadLine();

        }
    }
}
