namespace Microsoft.Quantum.Canon
{
    open Microsoft.Quantum.Primitive;
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
            
            if(maxCoefficients == 2){
                // Termination case
                Exp([PauliZ], coefficients[0], qubits);
                R1(coefficients[0]+coefficients[1], qubits[0]);
            }
            else{
                // Compute new coefficients.
                let (coefficients0, coefficients1) = MultiplexorZComputeCoefficients_(coefficients + padZeros);
                MultiplexorZ_(coefficients1, BigEndian(qubits[1..Length(qubits)-1]), qubits[0]);
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
    operation MultiplexorPauli(coefficients:Double[], pauliString: Pauli[], control: BigEndian, target: Qubit[]) : (){
        body{
            if(Length(pauliString)!= Length(target)){
                fail $"operation MultiplexorPauli -- Length of pauliString ({pauliString}) must be equal to number of of control ({pauliString}).";
            }
            if(Length(target) > 1){
                fail $"operation MultiplexorPauli -- Functionality for Length of pauliString ({pauliString}) > 1 not implemented.";
            }   
            elif(Length(target) == 0){
                // Implement diagonal phase operator
                (DiagonalUnitary(coefficients))(control);
            }
            elif(Length(target) == 1){
                if(pauliString[0] == PauliZ){
                    (MultiplexorZ(coefficients))(control, target[0]);
                }
                elif(pauliString[0] == PauliX){
                    WithCA(H, (MultiplexorZ(coefficients))(control, _), target[0]);
                }
                elif(pauliString[0] == PauliY){
                    //FIXME: let op =  BindCA([(Adjoint S); H]);
                    //WithCA(BindCA([(Adjoint S); H]), MultiplexorZ(coefficients, control, _), target[0]);
                    let op = WithCA(H, (MultiplexorZ(coefficients))(control, _), _);
                    WithCA(Adjoint S, op, target[0]);
                }
                else{
                    // Implement diagonal phase operator
                    fail $"operation MultiplexorPauli -- diagonal phase operator not implemented.";
                }
            }


        }
        adjoint auto
        controlled auto
        adjoint controlled auto
    }

    // Diagonal gate is a special kind of multiplexor
    // We will need to track the global phase in the controlled version.
    
}
