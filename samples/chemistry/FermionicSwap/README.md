---
    page_type: sample
    languages:
    - qsharp
    - csharp
    products:
    - qdk
    description: "This sample demonstrates implementation of a fermionic swap network library, performing data processing necessary to construct a swap network in C# and passing the resulting data to Q# code."
    urlFragment: validating-quantum-mechanics
    ---
    # Fermionic swap network implementation.

    This sample demonstrates:
    - Implementation of a C# library for constructing fermionic swap networks for Hamiltonians, expressed using QDK data structures. Currently Dense one-body hamiltonians and rectangular lattices are implemented.
    - Q# code that evolves Trotterized Hamiltonians as swap networks.
    - A modified version of the SimulateHubbardHamiltonian sample which uses swap networks.

    Fermionic swap networks reduce the cost of Trotterized Hamiltonian evolution by amortizing Jordan-Wigner circuit-weight costs, repeatedly permuting the Jordan-Wigner ordering and performing evolutions when they admit low-weight circuits. Fermionic swap networks are described [here](https://arxiv.org/abs/1711.04789). The network used for Hubbard hamiltonians is described [here](https://arxiv.org/abs/2001.08324).