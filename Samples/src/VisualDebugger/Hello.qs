namespace vis_sim {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;

    operation HelloQ() : Unit {
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
}
