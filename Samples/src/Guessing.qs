namespace Microsoft.Quantum.Guessing
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

	//The following algorithm answers the following question:
	//let X = {0,1} with a probability distribution P(0) = 1/2 = P(1);
	//if an element of X is picked, or formally, if there is a function
	//f : * --> X, where * is the one-point set, what is the value of f?
	//Or which element was picked?
	/////////////////////////////////////////////////////////////////////////
	//We use one qubit to model X, where |0> corresponds to 0 and |1> to 1.
	//Then we use another qubit to infer the state of the first qubit, using
	//the CNOT gate.
	////////////////////////////////////////////////////////////////////////
    
    operation Guess () : Result 
	{

	   
		mutable result2 = Zero;
		mutable result1 = Zero;

        using (qubits = Qubit[2])
		{
		   
		   //The qubit qubits[0] is X. We apply the Hadamard gate 
		   //because there is an equal probability to pick either 0 or 1.

		    H(qubits[0]);

			//Picking an element of X amounts to measure qubits[0]. We will
			//not output the result of that measurement, which amounts to us
			//not knowing which element is picked.

			set result1 = M(qubits[0]);

			//Applying the CNOT gate creates entanglement.

			CNOT(qubits[0],qubits[1]);

			set result2 = M(qubits[1]);

			ResetAll(qubits);


		}
		//Upon measuring qubits[1], we can infer the state of qubits[0], which
		//amounts to knowing which element of x was picked.

		return result2;
    }
}
