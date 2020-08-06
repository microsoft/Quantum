namespace Microsoft.Quantum.Samples.Hardware.Syndrome
{
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Measurement;
	open Microsoft.Quantum.Arrays;

	operation ControlledPauli(basis: Pauli, control: Qubit, target: Qubit): Unit {
		if (PauliZ == basis) {
			CZ(control, target);
		}
		if (PauliX == basis) {
			CX(control, target);
		}
		if (PauliY == basis) {
			CY(control, target);
		}
	}

	operation BasisMeasure(basis_qubit: (Pauli, Qubit)): Result {
		let (basis, qubit) = basis_qubit;
		let result = Measure([basis], [qubit]);
		Reset(qubit);
		return result;
	}

	operation Prepare(qubit: Qubit, value: Bool, basis: Pauli): Unit {
		if (value) {
			X(qubit);
		}
		PrepareQubit(basis, qubit);
	}

	operation SamplePseudoSyndrome (
			input_values: Bool[],
			encoding_bases: Pauli[], 
			indexes: Int[]
	): Result[] {
		using ((block, ancilla) = (Qubit[Length(input_values)], Qubit())) {
			for ((qubit, value, basis) in Zip3(block, input_values, encoding_bases)) {
				Prepare(qubit, value, basis);
			}
			H(ancilla);
			for (index in indexes) {
				ControlledPauli(encoding_bases[index], ancilla, block[index]);
			}
			Reset(ancilla);
			return ForEach(BasisMeasure, Zip(encoding_bases, block));
		}
	}
}