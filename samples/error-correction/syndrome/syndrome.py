# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
"""
Script for running Pseudo-syndrome example as defined in Syndrome.qs.
This script takes the number of data qubits as input.

Example usage:
    python syndrome.py -q 5
"""

import numpy as np
import qsharp
import argparse

from Microsoft.Quantum.Samples.ErrorCorrection.Syndrome import SamplePseudoSyndrome

parser = argparse.ArgumentParser(
    prog="PseudoSyndrome",
    description="Program for running a PseudoSyndrome circuit that detects \
        random errors on qubits in gate sequence."
)
parser.add_argument("-q", "--qubits", type=int, default=1)

if __name__ == "__main__":
    args = parser.parse_args()
    # To be refactored to qsharp.Pauli
    # (See IQSharp ticket https://github.com/microsoft/iqsharp/issues/256)
    paulis = ["PauliX", "PauliY", "PauliZ"]
    qubit_indices = list(range(args.qubits))
    np.random.shuffle(qubit_indices)
    input_values = [np.random.rand() > .5 for n in range(args.qubits)]
    encoding_bases = [np.random.choice(paulis) for n in range(args.qubits)]
    result = SamplePseudoSyndrome.simulate(
        inputValues=input_values,
        encodingBases=encoding_bases,
        qubitIndices=qubit_indices)
    auxiliary, data = result

    print(f"Inputs: {[int(val) for val in input_values]}\
            \nBases: {encoding_bases}\
            \nQubit indices: {qubit_indices}")
    print(f"Auxiliary: {auxiliary}")
    print(f"Data qubits: {data}")
