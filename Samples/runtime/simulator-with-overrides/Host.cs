// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.SimulatorWithOverrides
{
    class Host
    {
        static void Main(string[] args)
        {
            using var qsim = new FaultyMeasurementsSimulator();
            DoCorrelatedMeasurements.Run(qsim).Wait();
        }
    }
}
