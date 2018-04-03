// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;
    /// # Summary
    /// `MeasureInteger` reads out the content of a quantum register and converts
    /// it to an integer of type `Int`. The measurement is performed with respect
    /// to the standard computational basis, i.e., the eigenbasis of `PauliZ`.
    ///
    /// # Input
    /// ## target
    /// A quantum register which is assumed to be in little endian encoding.
    ///
    /// # Output
    /// An unsigned integer that contains the measured value of `target`.
    ///
    /// # Remarks
    /// Ensures that the register is set to 0.

    /// Register that encodes an unsigned integer in big-endian order. The qubit with index 0 encodes the highest bit of an unsigned integer
    ///
    /// # Summary
    /// Unitary |0><0| \otimes Exp(Pauli, r0) + ...
    ///
    /// # Input
    /// ## coefficients
    /// List of rotation angles r0 r1 r2 r3 .... 
    /// ## pauli
    /// Generator of rotation. Must be either PauliY or PauliZ TODO:: extend this to PauliX
    ///
    function MultiplexorZ(coefficients: Double[]) : ((BigEndian, Qubit) => () : Adjoint, Controlled){
        return MultiplexorZ_(coefficients, _, _);
    }

    operation MultiplexorZ_(coefficients: Double[], control: BigEndian, target: Qubit) : () {
        body{
            // pad coefficients length to a power of 2.
            let maxCoefficients = 2^(Length(control));
            let padZeros = new Double[maxCoefficients - Length(coefficients)];
            
            if(maxCoefficients == 1){
                // Termination case
                Exp([PauliZ], coefficients[0], [target]);
            }
            else{
                // Compute new coefficients.
                let (coefficients0, coefficients1) = MultiplexorZComputeCoefficients_(coefficients + padZeros);
                MultiplexorZ_(coefficients0, BigEndian(control[1..Length(control)-1]), target);
                CNOT(control[0], target);
                MultiplexorZ_(coefficients1, BigEndian(control[1..Length(control)-1]), target);
                CNOT(control[0], target);
            }
        }
        adjoint auto
        controlled (controlRegister) {
            // pad coefficients length to a power of 2.
            let maxCoefficients = 2^(Length(control));
            let padZeros = new Double[maxCoefficients - Length(coefficients)];

            let controlZeros = new Double[maxCoefficients];
            let (coefficients0, coefficients1) = MultiplexorZComputeCoefficients_(controlZeros+coefficients+padZeros);
            
            MultiplexorZ_(coefficients0, control, target);
            (Controlled X)(controlRegister, target);
            MultiplexorZ_(coefficients1, control, target);
            (Controlled X)(controlRegister, target);
        }
        adjoint controlled auto
    }

    function DiagonalUnitary(coefficients: Double[]) : ((BigEndian) => () : Adjoint, Controlled){
        return DiagonalUnitary_(coefficients, _);
    }

    operation DiagonalUnitary_(coefficients: Double[], qubits: BigEndian) : () {
        body{
            if(Length(qubits) == 0){
                fail $"operation DiagonalUnitary -- Number of qubits must be greater than 0.";
            }

            // pad coefficients length to a power of 2.
            let maxCoefficients = 2^(Length(qubits));
            let padZeros = new Double[maxCoefficients - Length(coefficients)];
            
            // Compute new coefficients.
            let (coefficients0, coefficients1) = MultiplexorZComputeCoefficients_(coefficients + padZeros);
            MultiplexorZ_(coefficients1, BigEndian(qubits[1..Length(qubits)-1]), qubits[0]);            
            if(maxCoefficients == 2){
                // Termination case
                Exp([PauliI], 1.0 * coefficients0[0], qubits);
            }
            else{
                DiagonalUnitary_(coefficients0, BigEndian(qubits[1..Length(qubits)-1]));
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    function MultiplexorZComputeCoefficients_(coefficients: Double[]) : (Double[], Double[]) {
        let newCoefficientsLength = Length(coefficients)/2;
        mutable coefficients0 = new Double[newCoefficientsLength];
        mutable coefficients1 = new Double[newCoefficientsLength];
        for(idxCoeff in 0..newCoefficientsLength-1){
            set coefficients0[idxCoeff] = 0.5 * (coefficients[idxCoeff] + coefficients[idxCoeff + newCoefficientsLength]);
            set coefficients1[idxCoeff] = 0.5 * (coefficients[idxCoeff] - coefficients[idxCoeff + newCoefficientsLength]);
        }
        return (coefficients0, coefficients1);
    }

    /// Gate count of multiply-controlled version is twice that of uncontrolled version +
    /// twice of multiply-controlled NOT.
    operation MultiplexorPauli(coefficients:Double[], pauli: Pauli, control: BigEndian, target: Qubit) : (){
        body{
            if(pauli == PauliZ){
                (MultiplexorZ(coefficients))(control, target);
            }
            elif(pauli == PauliX){
                WithCA(H, (MultiplexorZ(coefficients))(control, _), target);
            }
            elif(pauli == PauliY){
                //FIXME: let op =  BindCA([(Adjoint S); H]);
                //WithCA(BindCA([(Adjoint S); H]), MultiplexorZ(coefficients, control, _), target);
                let op = WithCA(H, (MultiplexorZ(coefficients))(control, _), _);
                WithCA(Adjoint S, op, target);
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    operation MultiplexorUnitary<'T>(unitaries : ('T => () : Adjoint, Controlled)[], index: BigEndian, target: 'T) : () {
        body{
            if(Length(index) == 0){
                fail "MultiplexorUnitary failed. Number of index qubits must be greater than 0.";
            }
            if(Length(unitaries) > 0){
                let ancilla = new Qubit[0];
                MultiplexorUnitary_(unitaries, ancilla, index, target);
            }
        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    // NCT tree from https://arxiv.org/pdf/1711.10980.pdf
    operation MultiplexorUnitary_<'T>(unitaries : ('T => () : Adjoint, Controlled)[], ancilla: Qubit[], index: BigEndian, target: 'T) : () {
        body{
            let nIndex = Length(index);
            let nStates = 2^nIndex;
            let nUnitaries = Length(unitaries);
            
            let nUnitariesRight = MinI(nUnitaries, nStates/2);
            let nUnitariesLeft = MinI(nUnitaries, nStates);

            let rightUnitaries = unitaries[0..(nUnitariesRight -1)];
            let leftUnitaries = unitaries[nUnitariesRight..nUnitariesLeft - 1];
            let newControls = BigEndian(index[1..nIndex-1]);

            if(nUnitaries > 0){
                if(Length(ancilla) == 1 && nIndex==0){
                    // Termination case
                    (Controlled unitaries[0])(ancilla, target);
                }
                elif(Length(ancilla) == 0 && nIndex>=1){
                    // Start case
                    let newAncilla = [index[0]];
                    if(nUnitariesLeft > 0){
                        MultiplexorUnitary_(leftUnitaries, newAncilla, newControls, target);
                    }
                    X(newAncilla[0]);
                    MultiplexorUnitary_(rightUnitaries, newAncilla, newControls, target);
                    X(newAncilla[0]);
                }
                else{
                    // Recursion that reduces nIndex by 1 & sets Length(ancilla) to 1.
                    using(newAncilla = Qubit[1]){
                        (Controlled X)(ancilla + [index[0]], newAncilla[0]);
                        if(nUnitariesLeft > 0){
                            MultiplexorUnitary_(leftUnitaries, newAncilla, newControls, target);
                        }
                        (Controlled X)(ancilla, newAncilla[0]);
                        MultiplexorUnitary_(rightUnitaries, newAncilla, newControls, target);
                        (Controlled X)(ancilla, newAncilla[0]);
                        (Controlled X)(ancilla + [index[0]], newAncilla[0]);
                    }
                }
            }
        }
        adjoint auto
        controlled (controlRegister) {
            MultiplexorUnitary_(unitaries, controlRegister, index, target);
        }
        adjoint controlled auto
    }


    // Diagonal gate is a special kind of multiplexor
    // We will need to track the global phase in the controlled version.
    
}
