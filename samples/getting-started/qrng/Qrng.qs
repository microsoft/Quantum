// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Qrng {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    
    operation SampleQuantumRandomNumberGenerator() : Result {
        using (q = Qubit())  {  // Allocate a qubit.
            H(q);               // Put the qubit to superposition. It now has a 50% chance of being 0 or 1.
            return MResetZ(q);  // Measure the qubit value.
        }
    }
    
    @EntryPoint()
    operation SampleRandomNumber() : Int {
        let max = 10;
        Message($"Sampling a random number between 0 and {max}: ");
        let nBits = Floor(Log(IntAsDouble(max)) / LogOf2() + 1.);
    
        mutable bits = new Result[0];
        mutable output = 0;
        repeat {
            set bits = new Result[0];
            for (bit in 1 .. nBits) {
                set bits += [SampleQuantumRandomNumberGenerator()];
            }
            set output = ResultArrayAsInt(bits);
        }
        until (output <= max)
        fixup {
            Message($"{output} > {max}, trying again.");
        }

        return output;
    }
}
