namespace Microsoft.Quantum.Samples.Chemistry.VariationalQuantumEigensolver.Test {
    open Microsoft.Quantum.Samples.Chemistry.VariationalQuantumEigensolver;
    open Microsoft.Quantum.Intrinsic;

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
        let nSamples = 100;
        let result = EstimateEnergy(
            nQubits,
            hamiltonianTermList,
            inputState,
            energyOffset,
            nSamples
        );
    }
}