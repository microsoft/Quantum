// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Samples.OracleEmulation
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Extensions.Oracles;


    //////////////////////////////////////////////////////////////////////////
    // Defining and using simple emulated oracles ////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // Declare an oracle to be implemented in C#. See the
    // `PermutationOracle.Register` call in the driver for its implementation.
    operation HalfAnswer(x: Qubit[], y: Qubit[]) : Unit {
        // Since we are here only interested in the emulation feature, we do not
        // provide a native Q# implementation. In general, providing a Q#
        // implementation is encouraged because it allows for resource counting
        // and running on target machines without emulation capabilities.
        body (...)
        {
            fail "not implemented";
        }
        adjoint auto;
    }

    // Define a simple permutation function that is used below to create
    // another oracle.
    function DoubleAnswerFunc(x: Int, y: Int) : Int {
        return 84 ^^^ y;
    }

    // Measure and print the result.
    operation MeasureAndDisplay(message: String, register: Qubit[]) : Unit {
        let answer = MeasureInteger(LittleEndian(register));
        Message($"{message}{answer}.");
    }

    // # Summary
    // Here we demonstrate the use of three simple oracles. Each oracle ignores
    // the content of the first register and XOR's a constant number into the
    // second register.
    //
    // # Input
    // ## oracle
    // A quantum operation that implements an oracle
    // $$
    // \begin{align}
    //      O: \ket{x}\ket{y} \rightarrow \ket{x}\ket{f(x, y)}.
    // \end{align}
    // $$
    operation RunConstantOracles (oracle: ((Qubit[], Qubit[]) => Unit)) : Unit {
        Message("Querying the oracles...");

        // Prepare a one-qubit register `flag` and an eight-qubit register
        // `result`. Since all the oracles here ignore the flag, its length and
        // state do not matter.
        using ((flag, result) = (Qubit(), Qubit[8])) {
            H(flag);

            // Apply an oracle that was passed explicitly by the C# driver.
            oracle([flag], result);
            MeasureAndDisplay("The answer is ", result);

            // Apply an oracle that was declared above and implemented in the C#
            // driver.
            HalfAnswer([flag], result);
            MeasureAndDisplay("Half the answer is ", result);

            // Apply an oracle defined in terms of a Q# permutation function.
            PermutationOracle(DoubleAnswerFunc, [flag], result);
            MeasureAndDisplay("Twice the answer is ", result);

            // Apply an oracle to a superposition in result.
            for(i in 1..5) {
                H(result[7]);
                // Before the oracle is queried, the state of the result register is
                //      $\ket{y} = \ket{0} + \ket{128}$.
                // The oracle will map this to
                //      $\ket{y'} = \ket{42 \oplus 0} + \ket{42 \oplus 128} = \ket{42} + \ket{170}$.
                oracle([flag], result);
                MeasureAndDisplay("The answer might be ", result);
            }

            Reset(flag);
        }
    }


    //////////////////////////////////////////////////////////////////////////
    // Emulated arithmetic operations ////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // Prepare two `LittleEndian` registers in a computational basis state.
    operation PrepareSummands(numbers: (Int, Int), registers: (Qubit[], Qubit[])) : (LittleEndian, LittleEndian) {
        let x = LittleEndian(Fst(registers));
        let y = LittleEndian(Snd(registers));
        ApplyXorInPlace(Fst(numbers), x);
        ApplyXorInPlace(Snd(numbers), y);
        return (x, y);
    }

    // Measure and check that M(x) + y_init == M(y).
    operation MeasureAndCheckAddResult(y_init: Int, x: LittleEndian, y: LittleEndian): (Int, Int) {
        let mx = MeasureInteger(x);
        let my = MeasureInteger(y);
        Message($"Computed {mx} + {y_init} = {my} mod {2^8}");
        EqualityFactI((mx + y_init) % 2^8, my, "sum is wrong");
        return (mx, my);
    }

    // Modular addition of 8-bit integers.
    function ModAdd8(x: Int, y: Int) : Int {
        return (x + y) % (1 <<< 8);
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
        let adder = PermutationOracle(ModAdd8, _, _);
        let width = 8;

        // Two integers to initialize the registers.
        let numbers = (123, 234);

        // Write the numbers into registers and add them.
        using (registers = (Qubit[width], Qubit[width])) {
            // Prepare two `LittleEndian` registers, initialized to the values
            // in `numbers`.
            let (x, y) = PrepareSummands(numbers, registers);

            // Apply the add oracle. Note that the oracle expects two plain
            // `Qubit[]` registers, so the `LittleEndian` variables `x`, `y`
            // need to be unwrapped with the `!` operator.
            adder(x!, y!);

            // Measure the registers. Check that the addition was performed and
            // the input register `x` has not been changed.
            let (mx, my) = MeasureAndCheckAddResult(Snd(numbers), x, y);
            EqualityFactI(mx, Fst(numbers), "x changed!");
        }
        
        // Now do two additions in superposition.
        for(i in 1..5) {
            using (registers = (Qubit[width], Qubit[width])) {
                // Prepare x in the superposition $\ket{x} = \ket{123} + \ket{251}$.
                let (x, y) = PrepareSummands(numbers, registers);
                H(x![7]);

                // Apply the add oracle.
                adder(x!, y!);

                // Measure the registers. Check that the addition was performed and
                // the input register `x` has collapsed into either 123 or 251.
                let (mx, my) = MeasureAndCheckAddResult(Snd(numbers), x, y);
                Fact(mx == Fst(numbers) or mx == (Fst(numbers) + 2^7) % 2^width, "x changed!");
            }
        }
    }
}
