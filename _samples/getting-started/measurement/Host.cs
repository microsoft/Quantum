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

        static void Main(string[] args)
        {

            using (var qsim = new QuantumSimulator())
            {
                RunQuantumMain.Run(qsim).Wait();
            }

        }
    }
}
