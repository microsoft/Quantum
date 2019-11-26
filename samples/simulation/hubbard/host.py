# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import argparse
import qsharp
from Microsoft.Quantum.Samples.Hubbard import EstimateHubbardAntiFerromagneticEnergy

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Guess the order of a given permutation, using both classical and Quantum computing.")
    parser.add_argument(
        '-n',
        '--number-sites',
        type=int,
        help='Number of sites in the 1D Hubbard Model.(default=6)',
        default=6
    )
    parser.add_argument(
        '-u',
        '--u-coefficient',
        type=float,
        help='The repulsion coefficient.(default=1.0)',
        default=1.0
    )
    parser.add_argument(
        '-t',
        '--t-coefficient',
        type=float,
        help='the hpping coefficient.(default=0.2)',
        default=0.2
    )
    parser.add_argument(
        '-p',
        '--precision',
        type=int,
        help='The number of bits of precision in phase estimation.(default=7)',
        default=7
    )
    parser.add_argument(
        '-s',
        '--step-size',
        type=float,
        help='The trotter step size.(default=0.5)',
        default=0.5
    )
    parser.add_argument(
        '-a',
        '--attempts',
        type=int,
        help='The number of estimation attempts to perform.(default=10)',
        default=10
    )

    args = parser.parse_args()
    attempts = args.attempts
    # For this example, we'll consider a loop of size sites, each one of which
    # is simulated using two qubits.
    n = args.number_sites
    # Choose a repulsion term somewhat larger than the hopping term to favor
    # single-site occupancy.
    u = args.u_coefficient
    t = args.t_coefficient

    # We need to choose the number of bits of precision in phase estimation.
    # Bear in mind that this is bits of precision before rescaling by the trotterStepSize.
    # A smaller trotterStepSize would require more bits of precision to obtain
    # the same absolute accuracy.
    precision = args.precision

    # Choose a small trotter step size for improved simulation error.
    # This should be at least small enough to avoid aliasing of estimated
    # phases.
    step_size = args.step_size
    # Energy estimation error.
    error = 2 ** (-1 * precision) / step_size

    # Print our parameter definitions.
    print(f"""Hubbard model ground state energy estimation:
        {n} sites
        {u} repulsion term coefficient
        {t} hopping term coefficient
        {precision} bits of precision
        {error} energy estimate error from phase estimation alone
        {step_size} time step
        {attempts} attempts""")

    # Since there's a finite chance of successfully projecting onto the ground state,
    # we will call our new operation through the simulator several times,
    # reporting the estimated energy after each attempt.
    for i in range(attempts):
        energy_est = EstimateHubbardAntiFerromagneticEnergy.simulate(
            nSites=n,
            tCoefficient=t,
            uCoefficient=u,
            bitsPrecision=precision,
            trotterStepSize=step_size
        )
        print(f"Energy estimated in attempt {i}: {energy_est}")
