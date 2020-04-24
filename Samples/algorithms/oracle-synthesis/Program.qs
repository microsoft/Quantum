namespace IntegerFactorization {

    open Microsoft.Quantum.Samples.OracleSynthesis;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;


    @EntryPoint()
    operation Program () : Unit {  
        
        for (func in 0 .. (1 <<< 8) - 1) {
            if (not RunOracleSynthesisOnCleanTarget(func, 3)) {
                Message($"Result = false");
            }
        }

        for (func in 0 .. (1 <<< 8) - 1) {                
            if (not RunOracleSynthesis(func, 3)) {
                Message($"Result = false");
            }
        }
    }
}
