// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Samples.OracleEmulation
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Emulation;


    //////////////////////////////////////////////////////////////////////////
    // Defining and using simple emulated oracles ////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // Declare an `intrinsic` oracle that is implemented in C#. See the
    // `PermutationOracle.Register` call in the driver for its implementation.
    operation HalfAnswer(x: Qubit[], y: Qubit[]) : Unit {
        body intrinsic;
        adjoint intrinsic;
    }

    // Define a simple permutation function that is used below to create
    // another oracle.
    function DoubleAnswerFunc(x: Int, y: Int) : Int {
        return 84 ^^^ y;
    }

    // Measure and print the result.
    operation MeasureAndDisplay(message: String, register: Qubit[]) : Unit {
        let answer = MeasureInteger(LittleEndian(register));
        Message(message + $"{answer}.");
    }

    // # Summary
    // Here we demonstrate the use of three simple oracles. Each oracle ignores
    // the content of the first register and XOR's a constant number into the
    // second register.
    //
    // # Input
    // ## oracle
    // A quantum operation that implements an oracle
    //      $O: \ket{x}\ket{y} \rightarrow \ket{x}\ket{f(x, y)}$.
    operation RunConstantOracles (oracle: ((Qubit[], Qubit[]) => Unit)) : Unit {
        Message("Querying the oracles...");

        // Prepare a one-qubit register `x` and an eight-qubit register `y`.
        // Since all the oracles here ignore x, its length and state do not
        // matter.
        using (qubits = Qubit[9]) {
            let x = qubits[0];
            let y = qubits[1..8];
            H(x);

            // Apply an oracle that was passed explicitly by the C# driver.
            oracle([x], y);
            MeasureAndDisplay("The answer is ", y);

            // Apply an oracle that was declared as `intrinsic` above and
            // implemented in the C# driver.
            HalfAnswer([x], y);
            MeasureAndDisplay("Half the answer is ", y);

            // Apply an oracle defined in terms of a Q# permutation function.
            EmulateOracle(DoubleAnswerFunc, [x], y);
            MeasureAndDisplay("Twice the answer is ", y);

            // Apply an oracle to a superposition in y.
            for(i in 1..5) {
                H(y[7]);
                // Before the oracle is queried, the state of the y register is
                //      $\ket{y} = \ket{0} + \ket{128}$.
                // The oracle will map this to
                //      $\ket{y'} = \ket{42 \oplus 0} + \ket{42 \oplus 128} = \ket{42} + \ket{170}$.
                oracle([x], y);
                MeasureAndDisplay("The answer might be ", y);
            }

            Reset(x);
        }
    }


    //////////////////////////////////////////////////////////////////////////
    // Emulated arithmetic operations ////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // Modular addition of 8-bit integers.
    function ModAdd8(x: Int, y: Int) : Int {
        return (x + y) % (1 <<< 8);
    }

    // Prepare two `LittleEndian` registers in a computational basis state.
    operation PrepareSummands(qubits: Qubit[], numbers: Int[]) : (LittleEndian, LittleEndian) {
        let n = Length(qubits);
        let x = LittleEndian(qubits[0..n/2 - 1]);
        let y = LittleEndian(qubits[n/2..n-1]);
        InPlaceXorLE(numbers[0], x);
        InPlaceXorLE(numbers[1], y);
        return (x, y);
    }

    // Measure and check that M(x) + y_init == M(y).
    operation MeasureAndCheckAddResult(x: LittleEndian, y: LittleEndian, y_init: Int): (Int, Int) {
        let mx = MeasureInteger(x);
        let my = MeasureInteger(y);
        Message($"Computed {mx} + {y_init} = {my} mod {2^8}");
        AssertBoolEqual((mx + y_init) % 2^8 == my, true, "sum is wrong");
        return (mx, my);
    }

    // Here we demonstrate how to define and use emulated arithmetic operations.
    // Our example is modular addition of 8-bit integers as implemented by the
    // one-line function above. This defines already a permutation function on
    // the computational basis states of two 8-qubit registers:
    //      $\ket{m}\ket{n} \rightarrow \ket{m}\ket{m + n \mod 8}$.
    // We can hence directly turn this function into an emulated oracle.
    operation RunAddOracle() : Unit {
        Message("Running emulated addition...");

        // Turn the permutation function into an oracle operation acting on two
        // quantum registers.
        let adder = EmulateOracle(ModAdd8, _, _);

        // Two integers to initialize the registers.
        let numbers = [123, 234];

        // Write the numbers into registers and add them.
        using (qubits = Qubit[16]) {
            // Prepare two `LittleEndian` registers of 8 qubits each,
            // initialized to the values in `numbers`.
            let (x, y) = PrepareSummands(qubits, numbers);

            // Apply the add oracle. Note that the oracle expects two plain
            // `Qubit[]` registers, so the `LittleEndian` variables `x`, `y`
            // need to be unwrapped with the `!` operator.
            adder(x!, y!);

            // Measure the registers. Check that the addition was performed and
            // the input register `x` has not been changed.
            let (mx, my) = MeasureAndCheckAddResult(x, y, numbers[1]);
            AssertBoolEqual(mx == numbers[0], true, "x changed!");
        }
        
        // Now do two additions in superposition.
        for(i in 1..5) {
            using (qubits = Qubit[16]) {
                // Prepare x in the superposition $\ket{x} = \ket{123} + \ket{251}$.
                let (x, y) = PrepareSummands(qubits, numbers);
                H(x![7]);

                // Apply the add oracle.
                adder(x!, y!);

                // Measure the registers. Check that the addition was performed and
                // the input register `x` has not been changed.
                let (mx, my) = MeasureAndCheckAddResult(x, y, numbers[1]);
                AssertBoolEqual(mx == numbers[0] or mx == (numbers[0] + 2^7) % 2^8, true, "x changed!");
            }
        }
    }
}
