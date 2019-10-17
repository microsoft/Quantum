import argparse
import random
import qsharp 
from Microsoft.Quantum.Samples.OrderFinding import FindOrder

def get_order(perm, index):
	order = 1
	curr = index
	while index != perm[curr]:
		order += 1
		curr = perm[curr]
	return order

def guess_quantum(perm, index):
	#result = FindOrder.simulate(perm=perm, input=index)
	result = 0
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
	if perm[perm[perm[index]]] == index:
		return random.choice([1,3])
	return random.choice([2,4])

def guess_order(perm, index, shots):
	q_guesses = { k+1 :0 for k in perm}
	c_guesses = { k+1 :0 for k in perm}
	for i in range(shots):
		c_guesses[guess_classical(perm, index)] += 1
		q_guesses[guess_quantum(perm, index)] += 1
	for k, v in c_guesses.items():
		print(f"{k}: {v}")
	for k, v in q_guesses.items():
		print(f"{k}: {v}")


if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Factor Integers using Shor's algorithm.")
	parser.add_argument(
		'-p',
		'--permutation',
		nargs=4,
		help='number to be factored',
		default=[1,2,3,0]
		)
	parser.add_argument(
		'-i',
		'--index',
		type=int,
		help='number of trial to perform',
		default=0
		)
	args = parser.parse_args()
	guess_order([1,2,3,0], 0, 5)

