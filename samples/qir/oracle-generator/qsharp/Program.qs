namespace OracleCompiler {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;

    operation Majority3(inputs : (Qubit, Qubit, Qubit), output : Qubit) : Unit {
        // The implementation of this operation will be
        // automatically derived from the description in
        // OracleCompiler.Classical.Majority3
    }

    @EntryPoint()
    operation RunProgram() : Unit {
        InitOracleCompilerFor(OracleCompiler.Classical.Majority3);

        use (a, b, c) = (Qubit(), Qubit(), Qubit());
        use f = Qubit();

        for ca in [false, true] {
            for cb in [false, true] {
                for cc in [false, true] {
                    within {
                        if ca { X(a); }
                        if cb { X(b); }
                        if cc { X(c); }
                    } apply {
                        Majority3((a, b, c), f);
                        let result = IsResultOne(MResetZ(f));

                        Message($"{cc} {cb} {ca} -> {result}");
                    }
                }
            }
        }
    }

    internal function InitOracleCompilerFor<'In, 'Out>(func : 'In -> 'Out) : Unit {
        let _ = Microsoft.Quantum.Intrinsic.X;
        let _ = Microsoft.Quantum.Intrinsic.CNOT;
        let _ = Microsoft.Quantum.Intrinsic.CCNOT;
        let _ = func;
    }
}

namespace OracleCompiler.Classical {
    internal function Majority3(a : Bool, b : Bool, c : Bool) : Bool {
        return (a or b) and (a or c) and (b or c);
    }
}
