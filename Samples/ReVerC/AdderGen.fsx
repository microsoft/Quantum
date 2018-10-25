/// Gain access to the ReVerC namespace
#if INTERACTIVE
#r @"rever.dll"
#endif

open System.IO
open System

///////////////////////////////////////////////
// Example classical function                //
///////////////////////////////////////////////

/// Performs integer addition of two little-endian Boolean arrays
let carryRippleAdder n =
    <@
    fun (a : bool array) (b : bool array) ->
        let compute_carry (a : bool) (b : bool) (c : bool) =
            (a && (b <> c)) <> (b && c) // a && b <> a && c <> b && c

        let result = Array.zeroCreate(n)
        let mutable carry = false
        result.[0] <- a.[0] <> b.[0]
        for i in 1 .. n-1 do
            carry <- compute_carry a.[i-1] b.[i-1] carry
            result.[i]  <-  a.[i] <> b.[i] <> carry
        result           
    @>

/// Compiles a 2-bit adder (`ReVerC.compile (carryRippleAdder 2)`) and outputs the
/// circuit as a Q# operations `Adder` to the file "Adder.qs".
///
/// ReVerC is currently restricted to F# terms of the type
///   `'A -> ... -> 'B -> 'C`
/// where 'A ... 'B are Boolean or Boolean arrays, and 'C is a Boolean, 
/// Boolean array, or the Unit type. By convention, the above type is compiled to
/// a Q# operation of type
///   `('A, ..., 'B, 'C) => ()`
/// with Booleans and Boolean arrays mapped to Qubits and Qubit arrays, respectively.
/// If 'C is the unit type, it does not appear as a parameter in the Q# operation.
File.WriteAllText("Adder.qs", ReVerC.printQSharp "Adder" <| ReVerC.compile (carryRippleAdder 2) false ReVerC.Eager)
0
