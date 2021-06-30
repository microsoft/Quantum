// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.AzureSamples {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Preparation;

    operation PrepareBellPair(left : Qubit, right : Qubit) : Unit is Adj + Ctl {
        H(left);
        CNOT(left, right);
    }

    @EntryPoint()
    operation Teleport(prepBasis : Pauli, measBasis : Pauli) : Result {
        use msg = Qubit();
        use here = Qubit();
        use there = Qubit();

        PreparePauliEigenstate(prepBasis, msg);
        PrepareBellPair(here, there);
        Adjoint PrepareBellPair(msg, here);

        if (MResetZ(msg) == One)  { Z(there); }
        if (MResetZ(here) == One) { X(there); }

        let result = Measure([measBasis], [there]);
        Reset(there);

        return result;
    }

}
