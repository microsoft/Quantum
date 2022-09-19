---
page_type: sample
languages:
- qsharp
- cpp
products:
- qdk
description: "This sample shows how to automatically generate oracles from Boolean function specifications leveraging QIR"
---

# Generate quantum oracles from Q# functions using QIR

Implementing quantum oracles is difficult. Classical oracles are described as
black boxes in description of algorithms (see, e.g., Hamiltonian simulation,
Quantum phase estimation, or Grover’s algorithm). While the *quantum parts*
(reflection operator in Grover, QFT in QPE) of the algorithm are described in
detail, the oracle is a black box placeholder for some classical function, for
which no implementation is provided, or at most for some example. This sample
shows how to make use of the LLVM infrastructure to create a QIR-based tool that
can automatically generate Q# operations for such classical oracles from Q#
functions.

In the [Q# program](./qsharp/Program.qs), there is a classical implementation of
the majority-of-three function, which evaluates to true if two ore three of the
input variables are assigned true.

```qsharp
namespace Microsoft.Quantum.OracleGenerator.Classical {
    function Majority3(a : Bool, b : Bool, c : Bool) : Bool {
        return (a or b) and (a or c) and (b or c);
    }
}
```

A corresponding empty Q# operation (parent namespace, same name) is defined as
follows:

```qsharp
namespace Microsoft.Quantum.OracleGenerator {
    operation Majority3(inputs : (Qubit, Qubit, Qubit), output : Qubit) : Unit {
        // implementation will be derived automatically
    }
}
```

The oracle generator implemented in this sample automatically finds an optimized
implementation for `Majority3` based on a QIR representation of the program. The
sample uses the [LLVM compiler infrastructure project](https://llvm.org/) and
the [EPFL logic synthesis libraries](https://github.com/lsils/lstools-showcase)
to optimize the quantum operation implementation generated for the functions.

> **Note:** This QIR-based oracle generation sample is still in preview and
> depends on an alpha version of the QDK.  Also, the main purpose of this sample
> is to illustrate a capability offered by the QIR infrastructure, and *not*
> providing a general purpose oracle generator that supports arbitrary Q#
> functions.

## Prerequisites

You need an installation of LLVM, CMake, and the clang compiler in a version
that supports C++ 17.  Information on how to install LLVM on your system can
be found in the [qsharp-runtime
repository](https://github.com/microsoft/qsharp-runtime).

## Sample overview

- [qsharp](./qsharp): This folder contains the Q# project that will be compiled
  into QIR; it contains an empty operation for which the implementation will be
  automatically generated
- [host](./host): C++ host program that calls into the QIR code.
- [oracle-generator](./oracle-generator): A C++ program that takes QIR generated
  from the Q# compiler and adds implementation details to empty operations based
  on Q# functions in the original code.

## Compiling the sample

Perform the following steps:

```shell
mkdir build
cd build
cmake -DCMAKE_CXX_COMPILER=clang++ ..
make
```

This step may fail in case the file `LLVMConfig.cmake` cannot be found, which
should be installed alongside LLVM.  In this case, try to find that folder,
let's call it $LLVM_DIR, and explicitly set it as follows in the script above:

```shell
cmake -DCMAKE_CXX_COMPILER=clang++ -DLLVM_DIR=$LLVM_DIR ..
```

## Running the sample

Call from within the `build` directory:

```shell
./host/host_program
```

## Manifest

- [CMakeLists.txt](CMakeLists.txt) Main CMake build file that builds the Q# project, the oracle generation executable, and calls it on the generated QIR code before linking it with the host program.
- [qsharp/project.csproj](qsharp/project.csproj) Q# project file for the sample (building this project is triggered via CMake).
- [qsharp/Program.qs](qsharp/Program.qs) Q# program containing the oracle specification and the empty oracle operation to be generated.
- [host/CMakeLists.txt](host/CMakeLists.txt) C++ host program project file (will be called from the main CMake build).
- [host/main.cpp](host/main.cpp) Host program to link with the generated QIR code from the Q# project.
- [oracle-generator/CMakeLists.txt](oracle-generator/CMakeLists.txt) Oracle generator project file (can be used stand-alone, but is called from the main CMake file in this project).
- [oracle-generator/oracle_generator.cpp](oracle-generator/oracle_generator.cpp) Main entry point for the oracle generator.
- [oracle-generator/read_qir.hpp](oracle-generator/read_qir.hpp) Helper functions to create a logic network from an LLVM function, representing the input Q# function.
- [oracle-generator/write_qir.hpp](oracle-generator/write_qir.hpp) Helper functions to write a logic network into an LLVM function, representing the implementation for the empty Q# operation.
