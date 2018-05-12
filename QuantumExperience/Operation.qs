// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Quantum.Qasm
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

	//Puts a qubit in superposition using the Hadamard gate and measures it
    operation Hadamard () : (Result)
    {
        body
        {
			mutable result = Zero;			// set a mutable field to put the result in
			using (qubits = Qubit[1])		//Create a Qubit register
            {
				H(qubits[0]);				//Perform Hadamard on the Qubit, 
				                            //putting it in superposition (50/50)
				set result = M(qubits[0]);	//Measure the Qubit which was 50/50, 
											//so 50% true, 50% false  
				Reset(qubits[0]);			//Clean up the Qubit so it can be re-used
            }
			return result;
        }
    }

	/// # Summary
    /// Measurement example: create a state $1/\sqrt(2)(|00\rangle+|11\rangle)$ and measure 
    /// it in the Pauli-Z basis. 
    ///
    /// # Remarks
    /// It is asserted that upon measurement in the Pauli-Z basis a perfect coin toss of a 
    /// 50-50 coin results with outcomes "00" and "11".
    operation MeasurementBellBasis () : (Result, Result) {
        body {
            mutable result = (Zero, Zero);
            // The following using block creates a fresh qubit and initializes it in |0〉.
            using(qubits = Qubit[2]) {
			    H(qubits[0]);					//Perform Hadamard on the Qubit, 
												//putting it in superposition (50/50)
                CNOT(qubits[0],  qubits[1]);	//Create an entaglement using the CNOT
               
                // Finally, we measure each qubit in Z-basis and construct a tuple from the results.
				// This will result in a 50-50 coin results with outcomes "00" and "11".
                set result = (M( qubits[0]), M(qubits[1]));

                // This time we use the canon function ResetAll to reset all the qubits at once. 
                ResetAll(qubits);
            }
            // Finally, we return the result of the measurement.
            return result;
        }
    }
}
