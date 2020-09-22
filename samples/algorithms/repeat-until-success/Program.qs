// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.RepeatUntilSuccess {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Example of a Repeat-until-success algorithm implementing a circuit 
    /// decomposition by Paetznick & Svore.
    /// # References
    /// - [ *Adam Paetznick, Krysta M. Svore*,
    ///     Quantum Information & Computation 14(15 & 16): 1277-1301 (2014)
    ///   ](https://arxiv.org/abs/1311.1074)
    ///
    /// # Input
    /// ## gate
    /// Gate circuit to run ("simple" or "V")
    /// ## inputBasis
    /// Pauli basis in which to prepare input qubit
    /// ## inputValue
    /// Boolean value for input qubit (true maps to One, false maps to Zero)
    /// ## limit
    /// Integer limit to number of repeats of circuit
    /// ## numRuns
    /// Number of times to run the circuit
    ///
    /// # Remarks
    /// The program executes a circuit on a "target" qubit using an "auxiliary"
    /// qubit.
    /// The goal is to measure Zero for the auxiliary qubit.
    /// If this succeeds, the program will have effectively applied an 
    /// (I + i√2X)/√3 gate on the target qubit.
    /// If this fails, the program reruns the circuit up to <limit> times.
    @EntryPoint()
    operation RunProgram(
        gate: String,
        inputValue : Bool,
        inputBasis : Pauli,
        limit : Int,
        numRuns : Int
    )
    : Unit {
        if (gate != "simple" and gate != "V") {
            Message($"Gate '{gate}' is invalid. Please specify a valid gate. Options are: 'simple' or 'V'.");
        } else {
            for (n in 0 .. numRuns - 1) {
                if (gate == "simple") {
                    let (success, result, numIter) = CreateQubitsAndApplySimpleGate(
                        inputValue, inputBasis, limit
                    );
                    Message($"({success}, {result}, {numIter})");
                } elif (gate == "V") {
                    let (success, result, numIter) = CreateQubitsAndApplyRzArcTan2(
                        inputValue, inputBasis, limit
                    );
                    Message($"({success}, {result}, {numIter})");
                }
            }
        }
    }
}
