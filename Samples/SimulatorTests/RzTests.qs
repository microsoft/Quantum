// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Quantum.SimulatorTests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation Rz0RotationTest () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Rz(0.0,qs[0]);

                Assert([PauliZ], qs, Zero, "Ignored rotation results in |0> state");
            }
            
            Message("Test passed");
        }
    }

	operation RzPiRotationTest () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Rz(PI(),qs[0]);

                Assert([PauliZ], qs, Zero, "PI rotation results in |0> state, becasue we rotated the top");
            }
            
            Message("Test passed");
        }
    }

	operation RzNaNRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Rz(0.0/0.0,qs[0]);
			}
        }
    }

	operation RzInfinitiRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Rz(1.0/0.0,qs[0]);
			}
        }
    }

	operation RzNegativeInfinitiRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Rz(1.0/0.0,qs[0]);
			}
        }
    }
}