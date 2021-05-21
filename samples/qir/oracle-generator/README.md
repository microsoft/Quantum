# Compile quantum oracles from Q# functions using QIR

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
namespace OracleCompiler.Classical {
    function Majority3(a : Bool, b : Bool, c : Bool) : Bool {
        return (a or b) and (a or c) and (b or c);
    }
}
```

A corresponding empty Q# operation (parent namespace, same name) is defined as
follows:

```qsharp
operation Majority3(inputs : (Qubit, Qubit, Qubit), output : Qubit) : Unit {
    // implementation will be derived automatically
}
```

The oracle compiler implemented in this sample automatically finds an optimized
implementation for `Majority3` based on a QIR representation of the program.

## Prerequisites

You need an installation of LLVM 11, the clang compiler in a version that
supports C++ 17, and .NET 5.0.

## Repository overview

* [qsharp](./qsparh): This folder contains the Q# project that will be compiled
  into QIR; it contains an empty operation for which the implementation will be
  automatically generated
* [host](./host): C++ host program that calls into the QIR code.
* [oracle-compiler](./oracle-compiler): A C++ program that takes QIR generated
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

This step may fail in case the file `LLVMCOnfig.cmake` cannot be found, which
should be installed alongside LLVM.  In this case, try to find that folder,
let's call it $LLVM_DIR, and explicitly set it as follows in the script above:

```shell
cmake -DCMAKE_CXX_COMPILER=clang++ -DLLVM_DIR=$LLVM_DIR ..
```

## Running the sample

Call from within the `build` directory:

```
./host/host_program
```
