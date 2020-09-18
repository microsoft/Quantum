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
                ((0.001, 0.0), [2, 0]),
                ((-0.001, 0.0), [3, 1]),
                ((-0.001, 0.0), [2, 3, 1, 0]),
                ((1.0, 0.0), [0, 1])
            ]
        );
        let parameters = [0.001, -0.001, -0.001];
        let energyOffset = -0.098834446;
        // Large number of samples is slow because of simulation settings
        // let nSamples = 1000000000000000000;
        let nSamples = 10;
        let fci_value = -1.1372704220924401;
        let result = EstimateEnergy(
            nQubits,
            hamiltonianTermList,
            inputState,
            energyOffset,
            nSamples
        );
        Message($"Energy evaluated at {parameters} : {result}");
        Message($"Difference with FCI value: {result - fci_value}");
    }
}