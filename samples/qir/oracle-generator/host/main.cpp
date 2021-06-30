// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <iostream>

#include <QirContext.hpp>
#include <SimFactory.hpp>

// This is the function corresponding to the QIR entry-point.
//
// The entry point function in the Q# program is
// `operation RunProgram() : Unit { ... }` and lives
// in the namespace `Microsoft.Quantum.OracleGenerator`.
//
// This gets mapped into an LLVM function with the name
// `OracleGenerator__RunProgram` (periods in the fully-qualified
// name are translated into two underscores).  The Q# Unit
// type corresponds to the `void` type in C++.
extern "C"
{
    void Microsoft__Quantum__OracleGenerator__RunProgram();
}

int main()
{
    using namespace Microsoft::Quantum;
    auto sim = CreateToffoliSimulator();
    QirExecutionContext::Scoped ctx(sim.get(), false);

    Microsoft__Quantum__OracleGenerator__RunProgram();
    return 0;
}
