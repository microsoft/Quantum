namespace Quantum.ReVerC
{
	open Microsoft.Quantum.Primitive;
	open Microsoft.Quantum.Canon;

	/// Prepares a qubit register in the given basis state
	operation Prepare(initial: Result[], register: Qubit[]) : ()
	{
		body
		{
			for (idxQubit in 0..Length(initial)-1)
			{
				if (M(register[idxQubit]) != initial[idxQubit]) { X(register[idxQubit]); }
			}
		}
	}

	/// Performs the quantum addition of two basis states
	operation Add(ainit: Result[], binit: Result[]) : Int
	{
		body
		{
			mutable res = new Result[2];
			using (qubits = Qubit[6])
			{
				let a = qubits[0..1];
				let b = qubits[2..3];
				let c = qubits[4..5];
				Prepare(ainit, a);
				Prepare(binit, b);

				// Where the magic happens. In pre-build, the operation Adder is compiled by ReVerC during
				// the execution of AdderGen.fsx and placed in the source file Adder.qs
				Adder(a, b, c);

				set res[0] = M(c[0]);
				set res[1] = M(c[1]);

				ResetAll(qubits);

			}

			return ResultAsInt(res);
		}
	}
}
