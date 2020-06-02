# Using Q# with .NET #

This sample shows how to use Q# code with a classical host program written in .NET languages such as C# and F#.

*It is also possible to use Q# with VB.NET; for an example, see [this blog post](https://github.com/tcNickolas/MiscQSharp/tree/master/Quantum_VBNet).*

To use Q# with C# or F#, you can create a Q# library and then reference it from your .NET application.

The steps are as follows:

1. Create a Q# library `QuantumCode` and write your quantum code in it.
2. Create a C# or F# application (in this case a console app targeting .NET Core).
3. Add a reference to the Q# library to your C# or F# application. For example:

   You can use [Reference Manager](https://docs.microsoft.com/visualstudio/ide/how-to-add-or-remove-references-by-using-the-reference-manager) in Visual Studio to do that, or you can add the reference from the command line:

    ```PowerShell
    PS>  dotnet add .\fsharp\fsharp.fsproj reference .\qsharp\qsharp.csproj
    ```

   This will transitively include the [`Microsoft.Quantum.Development.Kit` NuGet package](https://www.nuget.org/packages/Microsoft.Quantum.Development.Kit) to your C# or F# application.
   You will not be writing any Q# code in `csharp.csproj` or `fsharp.fsproj`, but you will need to use functionality provided by the Quantum Development Kit to create a quantum simulator to run your quantum code on, and to define data types used to pass the parameters to your quantum program.
4. Write the classical host program in your .NET application. 

## Q# Code in the Sample

This example uses the last problem from [this quantum kata](https://github.com/Microsoft/QuantumKatas/tree/master/DeutschJozsaAlgorithm), 
which solves a task similar to the Bernstein–Vazirani algorithm, but has a slightly more interesting classical answer verification code. 

The problem is stated as follows: You are given a black box quantum oracle which implements a classical function 𝐹 which takes 𝑛 digits of binary input and produces a binary output.
You are guaranteed that the function f can be represented as
𝐹(𝑥₀, ..., 𝑥ₙ₋₁) = Σᵢ (𝑟ᵢ 𝑥ᵢ + (1 - 𝑟ᵢ)(1 - 𝑥ᵢ)) mod 2 for some bit vector 𝑟 = (𝑟₀, …, 𝑟ₙ₋₁).
Your goal is to find a bit vector which can produce the given oracle. Note that (unlike in the Bernstein–Vazirani algorithm), it doesn't have to be the same bit vector as the one used to create the oracle; if there are several bit vectors that produce the given oracle, you can return any of them.

You can read more about quantum oracles [in the documentation](https://docs.microsoft.com/quantum/concepts/oracles).

The solution is actually easier than the Bernstein–Vazirani algorithm, and is more classical than quantum. Indeed, the expression for the function 𝐹 can be simplified as follows: 𝐹(𝑥₀, ..., 𝑥ₙ₋₁) = 2 Σᵢ 𝑟ᵢ 𝑥ᵢ + Σᵢ 𝑟ᵢ + Σᵢ 𝑥ᵢ + 𝑛 (mod 2) = Σᵢ 𝑟ᵢ + Σᵢ 𝑥ᵢ + 𝑛 (mod 2). You can see that the value of the function depends not on the individual values of 𝑥ᵢ, but only on the parity of their sum - that's not that much information to extract. If you apply the oracle to a qubit state |0...0⟩|0⟩, you'll get a state |0⋯0⟩|𝐹(0, ..., 0)⟩ = |0⋯0⟩|Σᵢ 𝑟ᵢ + 𝑛 (mod 2)⟩. If you measure the target qubit now, you'll get Σᵢ 𝑟ᵢ mod 2 if n is even, and Σᵢ 𝑟ᵢ + 1 mod 2 if 𝑛 is odd.
