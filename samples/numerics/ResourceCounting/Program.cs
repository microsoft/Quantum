// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System.Diagnostics;

namespace Microsoft.Quantum.Numerics.Samples
{
    class Program
    {
        static void Main(string[] args)
        {
            var sim = new ResourcesEstimator();

            var evaluationPoints = new QArray<double>(
                new double[] { 0 }
            );
            var polynomialCoefficients = new QArray<double>(
                new double[] {
                    0.9992759725166501, -0.16566707016968898,
                    0.007958079331694682, -0.0001450780334861007
                }
            );
            var odd = true;
            var even = false;

            Debug.Assert(!(odd && even));
            System.Console.Write($"Resource counting for P(x) = {polynomialCoefficients[0]}");
            if (odd)
                System.Console.Write("*x");
            for (int d = 1; d < polynomialCoefficients.Length; ++d)
                System.Console.Write($" + {polynomialCoefficients[d]}*" +
                                     $"x^{d + (odd ? d+1 : 0) + (even ? d : 0)}");
            System.Console.Write(".\n");
            int pointPos = 3;
            int numBits = 32;
            var res = EvaluatePolynomial.Run(sim, polynomialCoefficients,
                                             evaluationPoints, numBits, pointPos,
                                             odd, even).Result;
            System.Console.WriteLine(sim.ToTSV());
        }
    }
}

