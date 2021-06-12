# -*- coding: utf-8 -*-
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# # Validating Quantum Mechanics with the CHSH Game

# This sample demonstrates:
# - How to prepare entangled states with Q#.
# - How to measure part of an entangled register.
# - Using Q# to understand superposition and entanglement.
#
# In this sample, you can use Q# to prepare qubits in an entangled state, and to check that measuring these qubits lets you win a game known as the _CHSH game_ more often than you can without entanglement.
# This game helps us understand entanglement, and has even been used experimentally to help test that the universe really is quantum mechanical in nature.

import numpy as np
import random
from typing import Tuple

import qsharp
from Microsoft.Quantum.Samples.CHSHGame import PlayQuantumStrategy

def get_random_bits(n_bits=1):
    return [
        bool(random.getrandbits(1))
        for _ in range(n_bits)
    ] if n_bits > 1 else bool(random.getrandbits(1))

def referee_single_round() -> bool:
    """
    Play a single round of the CHSH game and referee to see if the quantum
    strategy won the round.
    """
    
    # Generate random inputs for each player.
    alice_input, bob_input = get_random_bits(2)
    
    # Check whether Alice or Bob should go first.
    alice_measures_first = get_random_bits(1)
    
    # Run the Q# program to get the parity of Alice's and Bob's answers.
    output_parity = PlayQuantumStrategy.simulate(
        aliceBit=alice_input,
        bobBit=bob_input,
        aliceMeasuresFirst=alice_measures_first
    )

    # Check if Alice and Bob won the round.
    return output_parity == (not (alice_input and bob_input))

def estimate_quantum_win_probability(n_trials : int) -> Tuple[float, float]:
    est = np.mean([
        referee_single_round()
        for _ in range(n_trials)
    ])

    return est, np.sqrt(est * (1 - est) / n_trials)

if __name__ == "__main__":
    est_win_pr, error = estimate_quantum_win_probability(400)
    print(f"Estimated quantum win probability: {est_win_pr:%} ± {error:%}")


