// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

open System.Diagnostics
// Namespace in which quantum code resides
open Microsoft.Quantum.Samples
// Namespace in which quantum simulator resides
open Microsoft.Quantum.Simulation.Simulators
// Namespace in which QArray resides
open Microsoft.Quantum.Simulation.Core

[<EntryPoint>]
let main _ =
    printfn "Hello, classical world!"
    // Create a full-state simulator
    use simulator = new QuantumSimulator()

    let parity = Seq.reduce (<>)

    // Construct the parameter to be passed to the quantum algorithm.
    // QArray is a data type for fixed-length arrays.
    // You can modify this parameter to see how the algorithm recovers 
    let oracleBits = new QArray<bool>([| false; true; false |])
    printfn "%A" oracleBits
    
    // Run the quantum algorithm
    let restoredBits = RunAlgorithm.Run(simulator, oracleBits).Result
    printfn "%A" restoredBits

    // Process the results: in this case, verify that:
    // - the length of the return array equals the length of the input array
    Debug.Assert(restoredBits.Length = oracleBits.Length, "Return array length differs from the input array length")
    // - the parity of the returned array matches the parity of the input one
    Debug.Assert((restoredBits |> parity) = (oracleBits |> parity), "Return array should have the same parity as the input one")

    0 // return an integer exit code
