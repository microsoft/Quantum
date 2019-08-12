namespace vis_sim {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;

    operation HelloQ() : Unit {
        Teleport();
        GroversSearch();
    }

    // Teleportation

    operation Teleport () : Unit {
        using ((msg, here, there) = (Qubit(), Qubit(), Qubit())) {
            H(msg);
            
            H(here);
            CNOT(here, there);

            CNOT(msg, here);
            H(msg);

            if (MResetZ(msg) == One)  { Z(there); }
            if (MResetZ(here) == One) { X(there); }
            H(there);
        }
    }

    // Grover's search
    // Based on the Grover's algorithm kata
    // https://github.com/microsoft/QuantumKatas/tree/master/GroversAlgorithm

    operation AllOnesPhaseOracle (register : Qubit[]) : Unit {
        Controlled Z(register[1...], register[0]);
    }

    operation AllZeroesPhaseOracle (register : Qubit[]) : Unit {
        ApplyWith(ApplyToEachA(X, _), AllOnesPhaseOracle, register);
    }

    operation GroverIteration (register : Qubit[], oracle : (Qubit[] => Unit)) : Unit {
        oracle(register);
        ApplyToEach(H, register);
        AllZeroesPhaseOracle(register);
        ApplyToEach(H, register);
    }

    operation GroversSearch () : Unit {
        let n = 3;
        using (register = Qubit[n]) {
            ApplyToEach(H, register);
            for (i in 1 .. Floor(Sqrt(PowD(2.0, IntAsDouble(n))))) {
                GroverIteration(register, AllOnesPhaseOracle);
            }
            ResetAll(register);
        }
    }
}
