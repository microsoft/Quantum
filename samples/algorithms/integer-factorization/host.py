import argparse
import qsharp
# Maybe try catching the error with from qsharp import IQSharpError
from Microsoft.Quantum.Samples.IntegerFactorization import FactorInteger

def factor_integer(number_to_factor, n_trials, use_robust_phase_estimation):
	""" Use Shor's algorithm to factor an integer.

	Shor's algorithm is a probabilistic algorithm and can fail with certain probability in several ways.
	For more details see Shor.qs.
	"""
	# Repeat Shor's algorithm multiple times because the algorithm is probabilistic.
	for i in range(n_trials):
		# Report the number to factor on each attempt.
		print("==========================================")
		print(f'Factoring {number_to_factor}')
		# Compute the factors
		output = FactorInteger.simulate(number=number_to_factor, useRobustPhaseEstimation=use_robust_phase_estimation)
		# If the run of Shor's algorithm fails it throws ExecutionFailException in Shor.qs but in the python wrapper it returns None.
		if output:
			factor1, factor2 = output
			print(f"Factors are {factor1} and {factor2}.")
		else:
			# Report the failed attempt.
			print("This run of Shor's algorithm failed.")

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Factor Integers using Shor's algorithm.")
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
		'--use-phase-estimation',
		action='store_true',
		help='if true uses Robust Phase Estimation, uses Quantum Phase Estimation.(default=False)',
		default=False
		)
	args = parser.parse_args()
	if args.number >= 1:
		factor_integer(args.number, args.trials, args.use_phase_estimation)
	else:
		print("Error: Invalid number. The number '-n' must be greater than or equal to 1.")