// -*- coding: utf-8 -*-
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Samples;

namespace Microsoft.Quantum.Numerics.Samples
{
    class Program
    {
        public static void Main(string[] args) {
            var sim = new ResourcesEstimator();
            RunProgram.Run(sim).Wait();
            Console.WriteLine(sim.ToTSV());
	}
    }
}

