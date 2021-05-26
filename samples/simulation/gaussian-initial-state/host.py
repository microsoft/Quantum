# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import json

import qsharp
from Microsoft.Quantum.Samples.GaussianPreparation import RunProgram

import numpy as np
import matplotlib.pyplot as plt

def main():
    n_qubits = 7
    recursive = True

    states = []

    # Add a new message handler to the IQ# client that listens for the output
    # of DumpMachine and DumpRegister. This will let us make nicer plots
    # in matplotlib.
    old_handler = qsharp.client._handle_message
    def handle_state_dump(message, **kwargs):
        if message['msg_type'] == 'display_data':
            data = json.loads(message['content']['data'].get('application/json', "null"))
            if data is not None and 'amplitudes' in data:
                states.append(data['amplitudes'])
                return

        old_handler(message, **kwargs)
    qsharp.client._handle_message = handle_state_dump

    # Once we have our handlers set up, we can go on and simulate our Q#
    # program that we use to prepare a Gaussian state.
    RunProgram.simulate(recursive=recursive, nQubits=n_qubits)

    # Read the probability amplitudes from the state we captured out of
    # DumpMachine / DumpRegister.
    real = [amplitude['Real'] for amplitude in states[0]]
    imag = [amplitude['Imaginary'] for amplitude in states[0]]

    # Plot the resulting state.
    plt.plot(np.arange(len(real)), real, label='Real')
    plt.plot(np.arange(len(imag)), imag, label='Imaginary')
    plt.legend()

    # Save the plot out to a file and show it to the screen.
    plt.savefig(f'wavefunction{"_recursive" if recursive else ""}.png')
    plt.show()

if __name__ == "__main__":
    main()
