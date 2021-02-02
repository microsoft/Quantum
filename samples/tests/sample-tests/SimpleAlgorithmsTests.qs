// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Samples.SimpleAlgorithms.HiddenShift;
    open Microsoft.Quantum.Samples.SimpleAlgorithms.DeutschJozsa;
    open Microsoft.Quantum.Samples.SimpleAlgorithms.BernsteinVazirani;
    open Microsoft.Quantum.Diagnostics;

    //////////////////////////////////////////////////////////////////////////
    // Tests for the Bernstein-Vazirani quantum algorithm ////////////////////
    //////////////////////////////////////////////////////////////////////////

    // For the tests of the Bernstein-Vazirani algorithm we create instances on
    // a fixed bit size, here n=4 bit, create all 2^n parity functions, invoke
    // `ParityOperationImpl` to pick up a Bool[] and check if that array is the
    // same as the pattern we used to define the parity function from.
    @Test("QuantumSimulator")
    operation TestBernsteinVazirani() : Unit {
        // setting the bit size of the problem
        let nQubits = 4;

        // now, we iterate through all the 2^n parity functions
        for idxInstance in 0 .. 2 ^ nQubits - 1 {
            let result = RunBernsteinVazirani(nQubits, idxInstance);
            EqualityFactI(result, idxInstance, $"was expecting {idxInstance} but measured {result}");
        }
    }


    //////////////////////////////////////////////////////////////////////////
    // Tests for the Hidden Shift quantum algorithm for bent functions ///////
    //////////////////////////////////////////////////////////////////////////

    // For the tests of the hidden shift quantum algorithm for bent functions,
    // we create instances on a fixed bit size, here n=4 bits, and for a fixed
    // bent function, here the IP function. We create all 2^n instances corresponding
    // to the possible shifts with respect to different Boolean patterns on n bits,
    // `HiddenShiftBentCorrelation` to pick up a Bool[] and check if that array is the
    // same as the pattern we used to define the hidden shift instance.
    @Test("QuantumSimulator")
    operation TestHiddenShift() : Unit {

        // total number of variables of the Boolean function is n = 2u where u is the
        // register size. Note that n has to be even in order for bent functions to exist.
        let nQubits = 4;

        // now, we iterate through all the 2^n parity functions
        for idxInstance in 0 .. 2 ^ nQubits - 1 {

            // the corresponding quantum operation is constructed, which
            // has signature Qubit[] => (), and then it is passed to the
            // quantum algorithm to reconstruct the shift.
            let result = RunHiddenShift(idxInstance, nQubits);

            // Finally, using an assertion from the Asserts subdomain of the
            // canon, we check if the measured result is equal to pattern.
            EqualityFactI(result, idxInstance, $"Was expecting {idxInstance} but measured {result}.");
        }
    }


    //////////////////////////////////////////////////////////////////////////
    // Tests for the Deutsch-Jozsa quantum algorithm /////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // For the tests of the Deutsch-Jozsa quantum algorithm, we create test cases of
    // varying bit sizes, including 2, 3, 4 bits. Each test case has the format
    // (#variables, market elements, isConstant?). We construct the corresponding
    // Boolean functions and send them to `IsConstantBooleanFunction` to determine
    // if the Boolean function is constant or balanced.
    @Test("QuantumSimulator")
    operation TestDeutschJozsa() : Unit {

        // setting up a few test cases of both, constant and balanced functions.
        let testList = [
            (2, [1, 2], false),
            (2, [0, 1, 2, 3], true),
            (3, [2, 3, 5, 6], false),
            (4, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], true),
            (4, [1, 2, 6, 8, 11, 12, 13, 14], false)
        ];

        // iterating through the array of test instances
        for (n, markedElements, result) in testList {
            // Finally, using an assertion from the Asserts subdomain of the
            // canon, we check if the measured result is equal to bool value.
            EqualityFactB(
                RunDeutschJozsa(n, markedElements),
                result,
                $"Contradiction in Deutsch–Jozsa case with marked elements {markedElements}: was expecting {result}."
            );
        }
    }
}
