// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic;

namespace Microsoft.Quantum.Samples.SimulatorWithOverrides
{
    /// <summary>
    /// A simulator which extends QuantumSimulator and redefines measurement operation 
    /// to introduce a bit-flip error happening before measurement with certain probability.
    /// </summary>
    public class FaultyMeasurementsSimulator : QuantumSimulator
    {
        /// <summary>
        /// The overriding definition for operation M
        /// </summary>
        public class M : QSimM
        {
            /// <summary>
            /// The probability with which the error will be introduced before measurement.
            /// </summary>
            const double flipProbability = 0.1;

            /// <summary>
            /// Random number generator used to decide when to introduce the error.
            /// </summary>
            private static readonly System.Random rnd = new System.Random();

            public M(FaultyMeasurementsSimulator m) : base(m) { }

            /// <summary>
            /// The actual definition of what the new operation does.
            /// </summary>
            public override Func<Qubit, Result> __Body__ {
                get {
                    // Get the original M operation to call it and process the results
                    Func<Qubit, Result> originalMeasurementOperation = base.__Body__;

                    // Get the X gate operation (used to introduce the error)
                    IUnitary<Qubit> gateX = this.__Factory__.Get<IUnitary<Qubit>>(typeof(X));

                    // The body of the operation is a lambda
                    return (qubit =>
                    {
                        // Introduce the X error with certain probability
                        if (rnd.NextDouble() < flipProbability)
                        {
                            gateX.Apply(qubit);
                        }

                        // Call the original (perfect) M operation to get final measurement results.
                        // Q# type Result which denotes measurement results maps to C# type with the same name
                        return originalMeasurementOperation(qubit);
                    });
                }
            }
        }
    }
}
