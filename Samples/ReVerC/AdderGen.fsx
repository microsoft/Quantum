open System.IO
open System
open ReVerC

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

/// Compiles a 2-bit adder (compile (carryRippleAdder 2)) and outputs the
/// circuit in Q# format with the operation name "adder" to the file "adder.qs".
///
/// By convention, a function with type "a -> ... -> b -> c" is compiled to an
/// operation with of type "a -> ... -> b -> c -> ()".
File.WriteAllText("adder.qs", printQSharp "adder" <| compile (carryRippleAdder 2) false Eager)
0
