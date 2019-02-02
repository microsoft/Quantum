// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.Python {
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    
    
    function HelloWorld (pauli : Pauli) : Unit {
        
        Message($"Hello, world! {pauli}");
    }
    
    
    operation NoisyHadamardChannelImpl (depol : Double, target : Qubit) : Unit {
        
        let idxAction = Random([1.0 - depol, depol]);
        
        if (idxAction == 0) {
            H(target);
        }
        else {
            PrepareSingleQubitIdentity(target);
        }
    }
    
    
    function NoisyHadamardChannel (depol : Double) : (Qubit => Unit) {
        
        return NoisyHadamardChannelImpl(depol, _);
    }
    
}


