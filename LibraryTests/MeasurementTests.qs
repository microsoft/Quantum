// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Primitive;
	open Microsoft.Quantum.Samples.Measurement;

    operation MeasurementTest () : () {
        body { 
            mutable resOne = Zero;
            set resOne = MeasurementOneQubit();
			mutable resTwo = (Zero, Zero);
            set resTwo = MeasurementTwoQubits();
			mutable resBell = (Zero, Zero);
            set resBell = MeasurementBellBasis();			
        }
    }
}
