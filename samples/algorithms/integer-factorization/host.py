import argparse
import qsharp
# Maybe try catching the error with from qsharp import IQSharpError
from Microsoft.Quantum.Samples.IntegerFactorization import FactorInteger

def factor_integer(number_to_factor, n_trials, use_robust_phase_estimation):
	for i in range(n_trials):
		print("==========================================")
		print(f'Factoring {number_to_factor}')
		output = FactorInteger.simulate(number=number_to_factor, useRobustPhaseEstimation=use_robust_phase_estimation)
		if output:
			factor1, factor2 = output
			print(f"Factors are {factor1} and {factor2}.")
		else:
			print("This run of Shor's algorithm failed.")

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Factor Integers using Shor's algorithm.")
	parser.add_argument(
		'-n',
		'--number',
		type=int,
		help='number to be factored',
		default=15
		)
	parser.add_argument(
		'-t',
		'--trials',
		type=int,
		help='number of trial to perform',
		default=10
		)
	parser.add_argument(
		'-u',
		'--use-phase-estimation',
		action='store_true',
		help='if true uses Robust Phase Estimation, uses Quantum Phase Estimation.',
		default=False
		)
	args = parser.parse_args()
	factor_integer(args.number, args.trials, args.use_phase_estimation)