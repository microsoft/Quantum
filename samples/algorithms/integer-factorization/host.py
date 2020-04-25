# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import argparse
import qsharp
from qsharp import IQSharpError
from Microsoft.Quantum.Samples.IntegerFactorization import FactorInteger


def factor_integer(number_to_factor, n_trials, use_robust_phase_estimation):
    """ Use Shor's algorithm to factor an integer.

    Shor's algorithm is a probabilistic algorithm and can fail with certain probability in several ways.
    For more details see Shor.qs.
    """
    # Repeat Shor's algorithm multiple times because the algorithm is
    # probabilistic.
    for i in range(n_trials):
        # Report the number to factor on each attempt.
        print("==========================================")
        print(f'Factoring {number_to_factor}')
        # Compute the factors
        try:
            output = FactorInteger.simulate(
                number=number_to_factor,
                useRobustPhaseEstimation=use_robust_phase_estimation,
                raise_on_stderr=True)
            factor_1, factor_2 = output
            print(f"Factors are {factor_1} and {factor_2}.")
        except IQSharpError as error:
            # Report the failed attempt.
            print("This run of Shor's algorithm failed:")
            print(error)



if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Factor Integers using Shor's algorithm.")
    parser.add_argument(
        '-n',
        '--number',
        type=int,
        help='number to be factored.(default=15)',
        default=15
    )
    parser.add_argument(
        '-t',
        '--trials',
        type=int,
        help='number of trial to perform.(default=10)',
        default=10
    )
    parser.add_argument(
        '-u',
        '--use-robust-pe',
        action='store_true',
        help='if true uses Robust Phase Estimation, otherwise uses Quantum Phase Estimation.(default=False)',
        default=False)
    args = parser.parse_args()
    if args.number >= 1:
        factor_integer(args.number, args.trials, args.use_robust_pe)
    else:
        print("Error: Invalid number. The number '-n' must be greater than or equal to 1.")
