# Using Q# with F# #

This sample shows how to use Q# code with a classical host program written in F#.

*It is also possible to use Q# with VB.NET; for an example, see [this blog post](https://github.com/tcNickolas/MiscQSharp/tree/master/Quantum_VBNet).*

Q# code is compiled to C# for the purposes of local simulation, so using Q# with C# is very straightforward, as described in the documentation. Using Q# with F# is a little less obvious, since you can't mix Q# and F# files in the same project. You have to create a Q# library (which will yield a .csproj project with only Q# files in it) and then reference it from a purely F# application.

The steps are as follows:

1. Create a Q# library `QuantumCode` and write your quantum code in it.
2. Create an F# application (in this case a console app targeting .NET Core) `FsharpDriver`.
3. Add a reference to the Q# library to the F# application.

   You can use [Reference Manager](https://docs.microsoft.com/visualstudio/ide/how-to-add-or-remove-references-by-using-the-reference-manager) in Visual Studio to do that, or you can add the reference from the command line:

    ```PowerShell
    PS>  dotnet add .\FsharpDriver\FsharpDriver.vbproj reference .\QuantumCode\QuantumCode.csproj
    ```
   
   This will transitively include the [`Microsoft.Quantum.Development.Kit` NuGet package](https://www.nuget.org/packages/Microsoft.Quantum.Development.Kit) to the F# application.
   You will not be writing any Q# code in `FsharpDriver`, but you will need to use functionality provided by the Quantum Development Kit to create a quantum simulator to run your quantum code on, and to define data types used to pass the parameters to your quantum program.
5. Write the classical driver in `VBNetDriver`.
   The code structure is similar to the [C# example](https://docs.microsoft.com/quantum/quickstart#step-3-enter-the-c-driver-code), so we won't go into the details here.


## Running the Sample

Open the `Quantum_Fsharp.sln` solution in Visual Studio and set project `FsharpDriver` as the startup project. Press Start to run the sample.


## Q# Code in the Sample

   This example uses the last problem from [this quantum kata](https://github.com/Microsoft/QuantumKatas/tree/master/DeutschJozsaAlgorithm), 
   which solves a task similar to the Bernstein–Vazirani algorithm, but has a slightly more interesting classical answer verification code. 
   
   The problem is stated as follows: You are given a black box quantum oracle which implements a classical function 𝐹 which takes 𝑛 digits of binary input and produces a binary output.
   You are guaranteed that the function f can be represented as
   𝐹(𝑥₀, ..., 𝑥ₙ₋₁) = Σᵢ (𝑟ᵢ 𝑥ᵢ + (1 - 𝑟ᵢ)(1 - 𝑥ᵢ)) mod 2 for some bit vector 𝑟 = (𝑟₀, …, 𝑟ₙ₋₁).
   Your goal is to find a bit vector which can produce the given oracle. Note that (unlike in the Bernstein–Vazirani algorithm), it doesn't have to be the same bit vector as the one used to create the oracle; if there are several bit vectors that produce the given oracle, you can return any of them.

   You can read more about quantum oracles [in the documentation](https://docs.microsoft.com/quantum/concepts/oracles).
   
   The solution is actually easier than the Bernstein–Vazirani algorithm, and is more classical than quantum. Indeed, the expression for the function 𝐹 can be simplified as follows: 𝐹(𝑥₀, ..., 𝑥ₙ₋₁) = 2 Σᵢ 𝑟ᵢ 𝑥ᵢ + Σᵢ 𝑟ᵢ + Σᵢ 𝑥ᵢ + 𝑛 (mod 2) = Σᵢ 𝑟ᵢ + Σᵢ 𝑥ᵢ + 𝑛 (mod 2). You can see that the value of the function depends not on the individual values of 𝑥ᵢ, but only on the parity of their sum - that's not that much information to extract. If you apply the oracle to a qubit state |0...0⟩|0⟩, you'll get a state |0⋯0⟩|𝐹(0, ..., 0)⟩ = |0⋯0⟩|Σᵢ 𝑟ᵢ + 𝑛 (mod 2)⟩. If you measure the target qubit now, you'll get Σᵢ 𝑟ᵢ mod 2 if n is even, and Σᵢ 𝑟ᵢ + 1 mod 2 if 𝑛 is odd.
