---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
description: "This sample implements Grover's search algorithm, an example of a quantum development technique known as amplitude amplification."
---

# Validating Quantum Mechanics with the CHSH Game #

This sample demonstrates:
- How to prepare entangled states with Q#.
- How to measure part of an entangled register.
- Using Q# to validate quantum mechanics.

In 1935, three physicists - Einstein, Podolsky, and Rosen - released a paper detailing an apparent contradiction in the workings of quantum mechanics.
The EPR Paradox (as it came to be known) posited a scenario in which quantum mechanics appeared to violate Heisenberg's uncertainty principle.
In certain cases (later known as "entanglement"), measuring a property of one particle gives knowledge of that same property of another particle; if a different property of the second particle is then measured, more information about the particle is learned than is allowed by Heisenberg's uncertainty principle.
The EPR trio assumed that measuring the first particle would have no effect on the second; in fact, it does!
When two particles are entangled, operations on one instantaneously affect the other, which dissolves the alleged paradox.
This violation of local realism was deeply troubling to Einstein, and he spent much of the remainder of his life trying to find an explanation which did not involve "spooky action at a distance" as he called it.


## Prerequisites ##

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample ##

This sample can be run in a number of different ways, depending on your preferred environment.

### Python in Visual Studio Code or the Command Line ###

At a terminal, run the following command:

```bash
python host.py
```

### C# in Visual Studio Code or the Command Line ###

At a terminal, run the following command:

```bash
dotnet run
```

### C# in Visual Studio 2019 ###

Open the `algorithms.sln` solution in Visual Studio and set `chsh-game/CHSHGame.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [Game.qs](./Game.qs): Q# code implementing the game.
- [host.py](./host.py): Python host program to call into the Q# sample.
- [Host.cs](./Host.cs): C# code to call the operations defined in Q#.
- [CHSHGame.csproj](./CHSHGame.csproj): Main C# project for the sample.

## Further resources ##

- [Measurement concepts](https://docs.microsoft.com/quantum/concepts/pauli-measurements)
- [Logging and assertion techniques](https://docs.microsoft.com/quantum/techniques/testing-and-debugging#logging-and-assertions)
