namespace Microsoft.Quantum.Samples.Chemistry.VariationalQuantumEigensolver {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Core;

    function ExpandedCoefficients(coeff : Double[], termType : Int) : Double[]{
    
        // Compute the numbers of coefficients to return
        mutable nCoeffs = 0;
        if (termType == 2) {set nCoeffs = 2;}
        elif (termType == 3) {set nCoeffs = 8;}
        else {set nCoeffs = 1;}

        mutable coeffs = new Double[nCoeffs];

        // Return the expanded array of coefficients
        if ((termType == 0) or (termType == 1)) {
	    set coeffs w/= 0 <- coeff[0];
	}
        elif ((termType == 2) or (termType == 3)) {
            for (i in 0..nCoeffs-1) {
                set coeffs w/= i <- coeff[i/2];
            }
	}

        return coeffs;
    }

    function VQEMeasurementOperators(
            nQubits : Int, 
            indices : Int[], 
            termType : Int
        ) : Pauli[][] {
    
        // Compute the size and initialize the array of operators to be returned
        mutable nOps = 0;
        if (termType == 2) {set nOps = 2;}
        elif (termType == 3) {set nOps = 8;}
        else {set nOps = 1;}

        mutable ops = new Pauli[][nOps];

        // Z and ZZ terms
        if ((termType == 0) or (termType == 1)) {
            mutable op = ConstantArray(nQubits, PauliI);
            for (idx in indices) {
                set op w/= idx <- PauliZ;
            }
            set ops w/= 0 <- op;
        }

        // PQRS terms set operators between indices P and Q (resp R and S) to PauliZ
        elif(termType == 3) {
            let compactOps = [[PauliX, PauliX, PauliX, PauliX], [PauliY, PauliY, PauliY, PauliY],
                              [PauliX, PauliX, PauliY, PauliY], [PauliY, PauliY, PauliX, PauliX],
                              [PauliX, PauliY, PauliX, PauliY], [PauliY, PauliX, PauliY, PauliX],
                              [PauliY, PauliX, PauliX, PauliY], [PauliX, PauliY, PauliY, PauliX]];
			      
            for (iOp in 0..7) {
                mutable compactOp = compactOps[iOp];

                mutable op = ConstantArray(nQubits, PauliI);
                for ((idx, pauli) in Zip(indices, compactOp)) {
                    set op w/= idx <- pauli;
                }
                for (i in indices[0]+1..indices[1]-1) {
                    set op w/= i <- PauliZ;
                }
                for (i in indices[2]+1..indices[3]-1) {
                    set op w/= i <- PauliZ;
                }
		set ops w/= iOp <- op; 
            }
	}

        // Case of PQ and PQQR terms
        elif(termType == 2) {
            let compactOps = [[PauliX, PauliX], [PauliY, PauliY]];

            for (iOp in 0..1) {
                mutable compactOp = compactOps[iOp];

                mutable op = ConstantArray(nQubits, PauliI);

                let nIndices = Length(indices);
                set op w/= indices[0] <- compactOp[0];
                set op w/= indices[nIndices-1] <- compactOp[1];
                for (i in indices[0]+1..indices[nIndices-1]-1) {
                    set op w/= i <- PauliZ;
                }

                // Case of PQQR term
                if (nIndices == 4) {
                     set op w/= indices[1] <- ((indices[0] < indices[1]) and (indices[1] < indices[3])) ? PauliI | PauliZ;
                }
                set ops w/= iOp <- op;
            }
        }

        return ops;
    }

    operation PrepareTrialState(
        terms: ((Double, Double), Int[])[],
        target: Qubit[]
    ) : Unit {
        let nTerms = Length(terms);
        let trotterStepSize = 1.0;

        // The last term is the reference state.
        let referenceState = PrepareTrialState((2, [terms[nTerms-1]]), _);
        
        PrepareUnitaryCoupledClusterState(referenceState, terms[0..nTerms-2], trotterStepSize, target);
    }

    operation TermExpectation(
        terms: ((Double, Double), Int[])[],
        measOp: Pauli[],
        nQubits: Int
    ) : Double {
        using (register = Qubit[nQubits]) {
            PrepareTrialState(terms, register);
        }
    }

    operation EstimateEnergy(
        nQubits : Int,
        hamiltonianTermList : (
                (Int[], Double[])[], 
                (Int[], Double[])[], 
                (Int[], Double[])[], 
                (Int[], Double[])[]
            ),
        inputState : ((Double, Double), Int[])[],
        energyOffset : Double,
        nSamples: Int
    ) : Double {
        mutable energy = 0;
        let (ZData, ZZData, PQandPQQRData, h0123Data) = hamiltonianTermList;
        let hamiltonianTermArray = [ZData, ZZData, PQandPQQRData, h0123Data];
        let nTerms = Length(ZData) + Length(ZZData) + Length(PQandPQQRData) + Length(h0123Data);

        for (termType in 0..Length(hamiltonianTermArray)-1) {
            let hamiltonianTerms = hamiltonianTermArray[termType];
            for (hamiltonianTerm in hamiltonianTerms) {
                let (qubitIndices, coefficient) = hamiltonianTerm;
                let measOps = VQEMeasurementOperators(nQubits, qubitIndices, termType);
                let coefficients = ExpandedCoefficients(coefficient, termType);

                mutable termEnergy = 0.;
                for ((coeff, op) in Zip(coefficients, measOps)) {
                    if (AbsD(coeff) >= 1e-10) {
                        set energy = TermExpectation(inputState, op, nQubits);
                        set termEnergy += (2. * termExpectation - 1.) * coeff;
                    }
                }
            }
        }

        return 1.0;
    }

    @EntryPoint()
    operation PerformTest() : Unit {
        let nQubits = 4;
        let hamiltonianTermList = (
            [
                ([0], [0.17120128499999998]),
                ([1], [0.17120128499999998]),
                ([2], [-0.222796536]),
                ([3], [-0.222796536])
            ],
            [
                ([0, 1], [0.1686232915]),
                ([0, 2], [0.12054614575]),
                ([0, 3], [0.16586802525]),
                ([1, 2], [0.16586802525]),
                ([1, 3], [0.12054614575]),
                ([2, 3], [0.1743495025])
            ],
            new (Int[], Double[])[0],
            [
                ([0, 1, 2, 3], [0.0, -0.0453218795, 0.0, 0.0453218795])
            ]
        );
        let inputState = (
            3,
            [
                ((-1.97094587e-06, 0.0), [2, 0]),
                ((1.52745368e-07, 0.0), [3, 1]),
                ((-0.113070239, 0.0), [2, 3, 1, 0]),
                ((1.0, 0.0), [0, 1])
            ]
        );
        let energyOffset = -0.098834446;
        let nSamples = 1000000000000000000;
        let result = EstimateEnergy(
            nQubits,
            hamiltonianTermList,
            inputState,
            energyOffset,
            nSamples
        );
    }
}
