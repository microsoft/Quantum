# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import argparse
import random
import qsharp
from Microsoft.Quantum.Samples.OrderFinding import FindOrder


def get_order(perm, index):
    """Returns the exact order (length) of the cycle that contains a given index.
    """
    order = 1
    curr = index
    while index != perm[curr]:
        order += 1
        curr = perm[curr]
    return order


def guess_quantum(perm, index):
    """Estimates the order of a cycle, using a quantum algorithm defined in the Q# file.

    Computes the permutation πⁱ(input) where i is a superposition of all values from 0 to 7.
    The algorithm then uses QFT to find a period in the resulting state.
    The result needs to be post-processed to find the estimate.
    """
    result = FindOrder.simulate(perm=perm, input=index)
    if result == 0:
        guess = random.random()
        # The probability distribution is extracted from the second column (m = 0) in Fig. 2's table
        # on the right-hand side, as shown in L.M.K. Vandersypen et al., PRL 85, 5452, 2000 (https://arxiv.org/abs/quant-ph/0007017).
        if guess <= 0.5505:
            return 1
        elif guess <= 0.5505 + 0.1009:
            return 2
        elif guess <= 0.5505 + 0.1009 + 0.1468:
            return 3
        return 4
    elif result % 2 == 1:
        return 3
    elif (result == 2) or (result == 6):
        return 4
    return 2


def guess_classical(perm, index):
    """Guesses the order (classically) for cycle that contains a given index

    The algorithm computes π³(index).  If the result is index, it
    returns 1 or 3 with probability 50% each, otherwise, it
    returns 2 or 4 with probability 50% each.
    """
    if perm[perm[perm[index]]] == index:
        return random.choice([1, 3])
    return random.choice([2, 4])


def guess_order(perm, index, n):

    # This object counts the number of times the quantum algorithm guesses a
    # given order.(so { order: count })
    q_guesses = {k + 1: 0 for k in perm}
    # This object counts the number of times the classical algorithm guesses a
    # given order.(so { order: count })
    c_guesses = {k + 1: 0 for k in perm}

    # Guess the order, 'n' amount of times.
    for i in range(n):
        # Count the classical guesses.
        c_guesses[guess_classical(perm, index)] += 1
        # Count the quantum guesses.
        q_guesses[guess_quantum(perm, index)] += 1

    print("\nClassical Guesses: ")
    for order, count in c_guesses.items():
        # Return the percentage of each order guess, which = (num_of_guesses /
        # total_guesses) * 100.
        print(f"{order}: {count / n : 0.2%}")

    print("\nQuantum Guesses: ")
    for order, count in q_guesses.items():
        # Return the percentage of each order guess, which = (num_of_guesses /
        # total_guesses) * 100.
        print(f"{order}: {count / n : 0.2%}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Guess the order of a given permutation, using both classical and Quantum computing.")
    parser.add_argument(
        '-p',
        '--permutation',
        nargs=4,
        type=int,
        help='provide only four integers to form a permutation.(default=[1,2,3,0])',
        metavar='INT',
        default=[
            1,
            2,
            3,
            0])
    parser.add_argument(
        '-i',
        '--index',
        type=int,
        help='the permutations cycle index.(default=0)',
        default=0
    )
    parser.add_argument(
        '-s',
        '--shots',
        type=int,
        help='number of repetitions when guessing.(default=1024)',
        default=1024
    )

    args = parser.parse_args()
    print(f"Permutation: {args.permutation}")
    print(f"Find cycle length at index: {args.index}")

    exact_order = get_order(args.permutation, args.index)
    print(f"Exact order: {exact_order}")

    guess_order(args.permutation, args.index, args.shots)
