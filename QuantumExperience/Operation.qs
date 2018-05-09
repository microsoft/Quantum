namespace Quantum.Quasm
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

	//Puts a qubit in superposition using the Hadamar gate and measures it
    operation Hadamar () : (Result)
    {
        body
        {
			mutable result = Zero;			// set a mutable field to put the result in
			using (qubits = Qubit[1])		//Create a Qubit register
            {
				H(qubits[0]);				//Perform Hadamar on the Qubit, 
				                            //putting it in superposition (50/50)
				set result = M(qubits[0]);	//Measure the Qubit which was 50/50, 
											//so 50% true, 50% false  
				Reset(qubits[0]);			//Clean up the Qubit so it can be re-used
            }
			return result;
        }
    }
}
