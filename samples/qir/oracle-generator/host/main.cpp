// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <iostream>

#include <QirContext.hpp>
#include <SimFactory.hpp>

extern "C"
{
    void OracleCompiler__RunProgram();
}

int main()
{
    using namespace Microsoft::Quantum;
    auto sim = CreateToffoliSimulator();
    QirExecutionContext::Scoped ctx(sim.get(), false);

    OracleCompiler__RunProgram();
    return 0;
}
