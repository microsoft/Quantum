// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.SimulatorWithOverrides
{
    class Host
    {
        static void Main(string[] args)
        {
            using FaultyMeasurementsSimulator qsim = new FaultyMeasurementsSimulator();
            DoCorrelatedMeasurements.Run(qsim).Wait();
        }
    }
}