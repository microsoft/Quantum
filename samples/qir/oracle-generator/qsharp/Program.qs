// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.OracleCompiler {
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
        InitOracleCompilerFor(Microsoft.Quantum.OracleCompiler.Classical.Majority3);

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

    // The QIR compiler optimizes code and removes functions and operations that
    // are never used.  By calling this function we ensure that (i) the function
    // for which the operation should be generated and (ii) intrinsic operations
    // used to implement the generated operation (X, CNOT, CCNOT) are present in
    // the QIR file emitted by the Q# compiler.
    internal function InitOracleCompilerFor<'In, 'Out>(func : 'In -> 'Out) : Unit {
        let _ = Microsoft.Quantum.Intrinsic.X;
        let _ = Microsoft.Quantum.Intrinsic.CNOT;
        let _ = Microsoft.Quantum.Intrinsic.CCNOT;
        let _ = func;
    }
}

namespace Microsoft.Quantum.OracleCompiler.Classical {
    // This is the classical implementation that serves as blueprint to generate
    // the empty Majority3 operation automatically.  Note that the input type
    // tuple and the output type correspond to the two inputs to the operation,
    // where `Bool` corresponds to `Qubit`.
    //
    // This function might return a `Bool` tuple type to represent multi-output
    // Boolean functions.  Then, the second argument in the operation must be a
    // `Qubit` tuple of equal size.
    internal function Majority3(a : Bool, b : Bool, c : Bool) : Bool {
        return (a or b) and (a or c) and (b or c);
    }
}
