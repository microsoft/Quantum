// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Quantum.SimulatorTests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    
    operation AllocateSingleQubitTest () : ()
    {
        body
        {
            using (qs = Qubit[1])
            {
                Assert([PauliZ], qs, Zero, "Newly allocated qubit must be in |0> state");
            }
            
            Message("Test passed");
        }
    }

	operation AllocateDualQubitTest () : ()
    {
        body
        {
            using (qs = Qubit[2])
            {
			    Assert([PauliZ;PauliZ], qs, Zero, "Newly allocated qubit must be in |0> state");
            }
            
            Message("Test passed");
        }
    }

	operation AllocateTrippleQubitTest () : ()
    {
        body
        {
            using (qs = Qubit[3])
            {
			    Assert([PauliZ;PauliZ;PauliZ], qs, Zero, "Newly allocated qubit must be in |0> state");
			}
            
            Message("Test passed");
        }
    }
}