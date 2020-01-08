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
    /// to return the correct measurement result with certain probability 
    /// and the opposite measurement result in the rest of the cases.
    /// </summary>
    public class FaultyMeasurementsSimulator : QuantumSimulator
    {
        /// <summary>
        /// The overriding definition for operation M
        /// </summary>
        public class M : QSimM
        {
            /// <summary>
            /// The probability with which the measurement result will be flipped.
            /// </summary>
            const double flipProbability = 0.1;

            /// <summary>
            /// Random numbers generator used to decide when to flip the result.
            /// </summary>
            private static readonly System.Random rnd = new System.Random();

            /// <summary>
            /// The X gate operation used to adjust the state to match flipped measurement results.
            /// </summary>
            private static IUnitary<Qubit> gateX;

            public M(FaultyMeasurementsSimulator m) : base(m) { }

            /// <summary>
            /// The actual definition of what the new operation does.
            /// </summary>
            public override Func<Qubit, Result> Body {
                get {
                    // Get the original M operation to call it and process the results
                    Func<Qubit, Result> originalMeasurementOperation = base.Body;

                    // Get the X gate
                    gateX = this.Factory.Get<IUnitary<Qubit>>(typeof(X));

                    // The body of the operation is a lambda
                    return (qubit =>
                    {
                        // Call the original M operation to get correct measurement results
                        Result originalResult = originalMeasurementOperation(qubit);

                        // Flip the measurement result with certain probability
                        if (rnd.NextDouble() < flipProbability) {
                            // Remember to adjust the state of the wave function
                            gateX.Apply(qubit);

                            return originalResult == Result.Zero ? Result.One : Result.Zero;
                        }
                        return originalResult;
                    });
                }
            }
        }
    }
}
