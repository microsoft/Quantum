namespace IntegerFactorization {

    open Microsoft.Quantum.Samples.OracleSynthesis;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation Program () : Unit {  
        
        mutable success = true;
        for (func in 0 .. (1 <<< 8) - 1) {
            set success = RunOracleSynthesisOnCleanTarget(func, 3) and success;
        }

        for (func in 0 .. (1 <<< 8) - 1) {                
            set success = RunOracleSynthesis(func, 3) and success;
        }

        let status = success ? "succeeded" | "failed";
        Message($"Execution {status}.");
    }
}
