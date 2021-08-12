namespace Microsoft.Quantum.Samples.DatabaseSearch {
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;

    @EntryPoint()
    operation RunDatabaseSearches() : Unit {
        RunRandomSearch();
        RunQuantumSearch();
        RunMultipleQuantumSearch();
    }

    internal operation RunRandomSearch() : Unit {
        // Let us investigate the success probability of classical random search. This corresponds
        // to the case where we only prepare the start state, and do not perform any Grover iterates
        // to amplify the marked subspace.
        let nIterations = 0;

        // We now define the size `N` = 2^n of the database to searched in terms of number of qubits
        // `n`. 
        let nDatabaseQubits = 3;
        let databaseSize = 2 ^ nDatabaseQubits;

        // We now execute the classical random search and verify that the success probability
        // matches the classical result of 1/N. Let us repeat 100 times to collect enough
        // statistics.
        let classicalSuccessProbability = 1.0 / IntAsDouble(databaseSize);
        let repeats = 1000;
        mutable successCount = 0;

        Message(
            "Classical random search for marked element in database.\n" +
            $"  Database size: {databaseSize}.\n" +
            $"  Success probability:  {classicalSuccessProbability}\n"
        );

        for attempt in 1 .. repeats {
            // Extract the marked qubit state.
            let (markedQubit, databaseRegister) = ApplyQuantumSearch(nIterations, nDatabaseQubits);
            set successCount += markedQubit == One ? 1 | 0;

            // Print the results of the search every 100 attempts.
            if attempt % 100 == 0 {
                Message(
                    $"Attempt {attempt}. " +
                    $"Success: {markedQubit},  " +
                    $"Probability: {RoundDigits(IntAsDouble(successCount) / IntAsDouble(attempt), 3)} " +
                    $"Found database index {databaseRegister}"
                );
            }
        }
    }

    internal operation RunQuantumSearch() : Unit {
        // Let us investigate the success probability of the quantum search.

        // We define the size `N` = 2^n of the database to searched in terms of number of qubits
        // `n`.
        let nDatabaseQubits = 6;
        let databaseSize = 2 ^ nDatabaseQubits;

        // We now perform Grover iterates to amplify the marked subspace.
        let nIterations = 3;

        // Number of queries to database oracle.
        let queries = nIterations * 2 + 1;

        // We now execute the quantum search and verify that the success probability matches the
        // theoretical prediction.
        let classicalSuccessProbability = 1.0 / IntAsDouble(databaseSize);
        let quantumSuccessProbability = Sin((2.0 * IntAsDouble(nIterations) + 1.0) * ArcSin(1.0 / Sqrt(IntAsDouble(databaseSize)))) ^ 2.0;
        let repeats = 100;
        mutable successCount = 0;

        Message(
            "\n\nQuantum search for marked element in database.\n" +
            $"  Database size: {databaseSize}.\n" +
            $"  Classical success probability: {classicalSuccessProbability}\n" +
            $"  Queries per search: {queries} \n" +
            $"  Quantum success probability: {quantumSuccessProbability}\n"
        );

        for attempt in 1 .. repeats {
            // Extract the marked qubit state.
            let (markedQubit, databaseRegister) = ApplyQuantumSearch(nIterations, nDatabaseQubits);
            set successCount += markedQubit == One ? 1 | 0;

            // Print the results of the search every 10 attempts.
            if attempt % 10 == 0 {
                let empiricalSuccessProbability = RoundDigits(IntAsDouble(successCount) / IntAsDouble(attempt), 3);

                // This is how much faster the quantum algorithm performs on average over the
                // classical search.
                let speedupFactor = RoundDigits(empiricalSuccessProbability / classicalSuccessProbability / IntAsDouble(queries), 3);

                Message(
                    $"Attempt {attempt}. " +
                    $"Success: {markedQubit},  " +
                    $"Probability: {empiricalSuccessProbability} " +
                    $"Speedup: {speedupFactor} " +
                    $"Found database index {databaseRegister}"
                );
            }
        }
    }

    internal operation RunMultipleQuantumSearch() : Unit {
        // Let us investigate the success probability of the quantum search with multiple
        // marked elements.

        // We define the size `N` = 2^n of the database to searched in terms of 
        // number of qubits `n`. 
        let nDatabaseQubits = 8;
        let databaseSize = 2 ^ nDatabaseQubits;

        // We define the marked elements. These must be smaller than `databaseSize`.
        let markedElements = [0, 39, 101, 234];
        let nMarkedElements = Length(markedElements);

        // We now perform Grover iterates to amplify the marked subspace.
        let nIterations = 3;

        // Number of queries to database oracle.
        let queries = nIterations * 2 + 1;

        // We now execute the quantum search and verify that the success 
        // probability matches the theoretical prediction. 
        let classicalSuccessProbability = IntAsDouble(nMarkedElements) / IntAsDouble(databaseSize);
        let quantumSuccessProbability = Sin((2.0 * IntAsDouble(nIterations) + 1.0) * ArcSin(Sqrt(IntAsDouble(nMarkedElements)) / Sqrt(IntAsDouble(databaseSize)))) ^ 2.0;
        let repeats = 10;
        mutable successCount = 0;

        Message(
            "\n\nQuantum search for marked element in database.\n" +
            $"  Database size: {databaseSize}.\n" +
            $"  Marked elements: {markedElements}" +
            $"  Classical success probability: {classicalSuccessProbability}\n" +
            $"  Queries per search: {queries} \n" +
            $"  Quantum success probability: {quantumSuccessProbability}\n"
        );

        for attempt in 1 .. repeats {
            // Extract the marked qubit state
            let (markedQubit, databaseRegister) = ApplyGroverSearch(markedElements, nIterations, nDatabaseQubits);
            set successCount += markedQubit == One ? 1 | 0;

            // Print the results of the search every attempt
            let empiricalSuccessProbability = RoundDigits(IntAsDouble(successCount) / IntAsDouble(attempt), 3);

            // This is how much faster the quantum algorithm performs on average
            // over the classical search.
            let speedupFactor = RoundDigits(empiricalSuccessProbability / classicalSuccessProbability / IntAsDouble(queries), 3);

            Message(
                $"Attempt {attempt}. " +
                $"Success: {markedQubit},  " +
                $"Probability: {empiricalSuccessProbability} " +
                $"Speedup: {speedupFactor} " +
                $"Found database index {databaseRegister}"
            );
        }
    }

    /// # Summary
    /// Rounds a number to a specific number of digits.
    ///
    /// # Input
    /// ## value
    /// The number to round.
    /// ## digits
    /// The number of digits to round to.
    ///
    /// # Output
    /// The rounded number.
    internal function RoundDigits(value : Double, digits : Int) : Double {
        return IntAsDouble(Round(value * 10.0 ^ IntAsDouble(digits))) / 10.0 ^ IntAsDouble(digits);
    }
}
