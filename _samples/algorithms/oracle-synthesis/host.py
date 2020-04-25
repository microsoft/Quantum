# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import qsharp
from Microsoft.Quantum.Samples.OracleSynthesis import RunOracleSynthesisOnCleanTarget, RunOracleSynthesis

if __name__ == "__main__":
    """Runs the Oracle Synthesis.

    The input 'func' is suppose to be an integer representation of a truth table.
    So if 'func' = 5 then the truth table is [1, 0, 1] which is actually encoded as [-1, 1, -1] => [true, false, true].
    The input 'vars' determines the size of the truth table such that the length of a the table = 2 ** 'vars'.
    So if 'vars' = 3 then the table will have 8 values.
    """
    print("Running Synthesis on clean target...")
    for i in range(256):
        # Implements oracle circuit for a given function, assuming that target qubit is initialized 0.
        # The adjoint operation assumes that the target qubit will be released to 0.
        res = RunOracleSynthesisOnCleanTarget.simulate(func=i, vars=3)
        if not res:
            print(f"Result = {res}")
    print("Complete.\n")

    print("Running Synthesis...")
    for i in range(256):
        # Implements oracle circuit for function
        res = RunOracleSynthesis.simulate(func=i, vars=3)
        if not res:
            print(f"Result = {res}")
    print("Complete.\n")
