namespace IntegerFactorization {

    open Microsoft.Quantum.Samples.IntegerFactorization;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;


    /// # Summary
    /// Factors an integer using Shor's quantum algorithm.
    ///
    /// # Input
    /// ## n
    /// Number to factor.
    @EntryPoint()
    operation Program (n : Int) : Unit {        
        // TODO: document and check restrictions for n
        let useRobustPhaseEstimation = true;

        Message($"==========================================");
        Message($"Factoring {n}");

        // Compute the factors
        let (factor1, factor2) = FactorInteger(n, useRobustPhaseEstimation);
        Message($"Factors are {factor1} and {factor2}");
    }
}
