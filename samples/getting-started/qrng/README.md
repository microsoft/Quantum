---
page_type: sample
languages:
- qsharp
- python
- csharp
products:
- qdk
description: "This sample implements a quantum random number generator using Q#, a good first example to teach how to use the language."
---

# Creating random numbers with quantum computing

This sample implements a quantum random number generator, a very simple application that is useful to learn how to write a first Q# code and it's integration with the host programs in C# or Python.

In the Q# code (Qrng.qs) you can find the code for extracting a random bit using quantum measurements over a qubit in superposition. For more information, you can take a look at the [full tutorial](https://docs.microsoft.com/quantum/quickstarts/qrng).

In the classical code (Host.cs for C# and host.py for Python) you will find the code to create a random integer from 0 to a maximum integer by invoking several times the Q# operation for extracting a random bit.


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

```dotnetcli
dotnet run
```

### C# in Visual Studio 2019 ###

Open the folder containing this sample in Visual Studio ("Open a local folder" from the Getting Started screen or "File → Open → Folder..." from the menu bar) and set `Qrng.csproj` as the startup project.
Press Start in Visual Studio to run the sample.

## Manifest ##

- [Qrng.qs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/qrng/Qrng.qs): Q# code implementing quantum operations for this sample.
- [Host.cs](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/qrng/Host.cs): C# code to interact with and print out results of the Q# operations for this sample.
- [Qrng.csproj](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/qrng/Qrng.csproj): Main C# project for the sample.
- [host.py](https://github.com/microsoft/Quantum/blob/master/samples/getting-started/qrng/host.py): Python code to interact with and print out results of the Q# operations for this sample.
