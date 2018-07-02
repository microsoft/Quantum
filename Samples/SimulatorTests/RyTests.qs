// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Quantum.SimulatorTests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation Ry0RotationTest () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Ry(0.0,qs[0]);

                Assert([PauliZ], qs, Zero, "Ignored rotation results in |0> state");
            }
            
            Message("Test passed");
        }
    }

	operation RyPiRotationTest () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Ry(PI(),qs[0]);

                Assert([PauliZ], qs, One, "PI rotation results in |1> state");

				ResetAll(qs);
            }
            
            Message("Test passed");
        }
    }

	operation RyNaNRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Ry(0.0/0.0,qs[0]);
			}
        }
    }

	operation RyInfinitiRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Ry(1.0/0.0,qs[0]);
			}
        }
    }

	operation RyNegativeInfinitiRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Ry(1.0/0.0,qs[0]);
			}
        }
    }
}