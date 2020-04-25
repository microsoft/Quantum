---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
description: "This sample uses the Q# standard libraries to implement a three-qubit bit-flip quantum error correction code."
urlFragment: bit-flip-code
---


# Bit-flip Quantum Code Sample

This sample demonstrates:

- Using the Q# standard libraries to implement a simple quantum error correction code.

## Prerequisites

- The Microsoft [Quantum Development Kit](https://docs.microsoft.com/quantum/install-guide/).

## Running the Sample

This sample can be run in a number of different ways, depending on your preferred environment.

### Python in Visual Studio Code or the Command Line

At a terminal, run the following command:

```bash
python host.py
```

### C# in Visual Studio Code or the Command Line

At a terminal, run the following command:

```dotnetcli
dotnet run
```

### C# in Visual Studio 2019

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `BitFlipCode.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest

- [BitFlipCode.qs](https://github.com/microsoft/Quantum/blob/master/samples/error-correction/bit-flip-code/BitFlipCode.qs): Q# code implementing quantum operations for this sample.
- [Host.cs](https://github.com/microsoft/Quantum/blob/master/samples/error-correction/bit-flip-code/Host.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [host.py](https://github.com/microsoft/Quantum/blob/master/samples/error-correction/bit-flip-code/host.py): Python host program to call into the Q# sample.
- [BitFlipCode.csproj](https://github.com/microsoft/Quantum/blob/master/samples/error-correction/bit-flip-code/BitFlipCode.csproj): Main C# project for the sample.

## Further resources

- [Error correction library concepts](https://docs.microsoft.com/quantum/libraries/standard/error-correction)
