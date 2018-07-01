// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Quantum.SimulatorTests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation R10RotationTest () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				R1(0.0,qs[0]);

                Assert([PauliZ], qs, Zero, "Ignored rotation results in |0> state");
            }
            
            Message("Test passed");
        }
    }

	operation R1PiRotationTest () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				R1(PI(),qs[0]);

                Assert([PauliZ], qs, Zero, "PI rotation results in |0> state");
            }
            
            Message("Test passed");
        }
    }

	operation R1NaNRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				R1(0.0/0.0,qs[0]);
			}
        }
    }

	operation R1InfinitiRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				R1(1.0/0.0,qs[0]);
			}
        }
    }

	operation R1NegativeInfinitiRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				R1(1.0/0.0,qs[0]);
			}
        }
    }
}