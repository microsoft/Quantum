import argparse
import random
import qsharp
from Microsoft.Quantum.Samples.IntegerFactorization import FindOrder

def guess_quantum(perm, index):
	result = FindOrder.simulate(perm=perm, input=index)
	if result == 0:
		guess = random.random()
        # the probability distribution is extracted from the second
        # column (m = 0) in Fig. 2's table on the right-hand side,
        # in the original and referenced paper.
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
	if perm[index] = index:
		return random.choice([1,3])
	return random.choice([2,4])

def guess_order(perm, index):
	pass

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Factor Integers using Shor's algorithm.")
	parser.add_argument(
		'-p',
		'--permutation',
		nargs=4,
		help='number to be factored',
		default=15
		)
	parser.add_argument(
		'-i',
		'--index',
		type=int,
		help='number of trial to perform',
		default=0
		)
	args = parser.parse_args()