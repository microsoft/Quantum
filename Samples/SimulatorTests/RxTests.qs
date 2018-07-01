// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Quantum.SimulatorTests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation Rx0RotationTest () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Rx(0.0,qs[0]);

                Assert([PauliZ], qs, Zero, "Ignored rotation results in |0> state");
            }
            
            Message("Test passed");
        }
    }

	operation RxPiRotationTest () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Rx(PI(),qs[0]);

                Assert([PauliZ], qs, One, "PI rotation results in |1> state");

				ResetAll(qs);
            }
            
            Message("Test passed");
        }
    }

	operation RxNaNRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Rx(0.0/0.0,qs[0]);
			}
        }
    }

	operation RxInfinitiRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Rx(1.0/0.0,qs[0]);
			}
        }
    }

	operation RxNegativeInfinitiRotationTestOutOfRange () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
				Rx(1.0/0.0,qs[0]);
			}
        }
    }
}