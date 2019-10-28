
from qsharp.chemistry import IndexConvention, FermionHamiltonian

class SpinOrbit:
	up = 0
	down = 1
	def __init__(self, orbital_index, spin):
		self.orbital_index = orbital_index
		self.spin = spin

	def to_int(self, index_convention=None, n_orbitals=1):
		if index_convention and index_convention == IndexConvention.HalfUp:
			return self.orbital_index + n_orbitals * self.spin
		return 2 * self.orbital_index + self.spin

class HermitianFermionTerm:
	def __init__(self, indices):
		self._ladder_seq = self.to_ladder_sequence(indices)
		self.normalize_canonical_order(self._ladder_seq)

	def to_ladder_sequence(self, indices):
		length = len(indices)
		if length % 2 == 1:
			raise Exception("Number of terms must be even length.")
		return [('u' if i < length/2 else 'd', indices[i]) for i in range(len(indices))]

	def _compare(self, a, b):
		for x, y in zip(a, b):
			if y > x:
				return -1
			elif y < x:
				return 1
		return 0

	def _is_index(self, creations, annihilation):
		# Creations must be in ascending order
		for i in range(1, len(creations)):
			if creations[i-1] > creations[i]:
				return False
		# Creations must be in decending order
		for i in range(1, len(annihilation)):
			if annihilation[i-1] < annihilation[i]:
				return False
		return True

	def _is_canonical(self, sequence):
		creations = []
		annihilation = []
		for rl, i in sequence:
			if rl == 'u':
				creations.append(i)
			else:
				annihilation.append(i)
		if not is_index(creations, annihilation):
			return False
		if len(creations) == len(annihilation) and compare(creations, reversed(annihilation)) > 0:
			return False
		elif len(creations) < len(annihilation):
			return False
		return True

	def normalize_canonical_order(self, sequence):
		if not is_canonical(sequence):
			terms = reversed([('u' if typ == 'd' else 'd', index) for typ, index in sequence]


orbital_i = 5

spin = SpinOrbit.down

spin_orbit = SpinOrbit(orbital_i, spin)

spin_orbit_index = spin_orbit.to_int()

spin_orbit_half = spin_orbit.to_int(IndexConvention.HalfUp, 6)

print("Spin-orbital representation:");
print(f"spinOrbital0: (Orbital, Spin) index: ({spin_orbit.orbital_index},{spin_orbit.spin}).");
print(f"spinOrbital0Int: (2 * Orbital + Spin) index: ({spin_orbit_index}).");
print(f"spinOrbital0HalfUpInt: (Orbital + nOrbitals * Spin) index: ({spin_orbit_half}).");

coefficient = 0.5

spin_orbitals_0 = [SpinOrbit(5, SpinOrbit.up), SpinOrbit(6, SpinOrbit.down)]
spin_orbitals_1 = [SpinOrbit(1, 0), SpinOrbit(1, 1), SpinOrbit(1, 1), SpinOrbit(1, 0)]

orbital_1_ints = [s.to_int() for s in spin_orbitals_1]

print(f"spinOrbital0.ToInts() as integers = fermionInts: {[s.to_int() for s in spin_orbitals_0]}) = [10, 12]")

#print(to_ladder_sequence([s.to_int() for s in spin_orbitals_0]))
#print(to_ladder_sequence([s.to_int() for s in spin_orbitals_1]))
fermion_term_0 = normalize_canonical_order(to_ladder_sequence([s.to_int() for s in spin_orbitals_0]))
fermion_term_1 = normalize_canonical_order(to_ladder_sequence([s.to_int() for s in spin_orbitals_1]))
# fermion_term_0 = FermionHamiltonian([s.to_int() for s in spin_orbitals_0])
# fermion_term_1 = FermionHamiltonian([s.to_int() for s in spin_orbitals_1])
# fermion_term_2 = FermionHamiltonian([s.to_int() for s in [SpinOrbit(2, 0), SpinOrbit(2, 1), SpinOrbit(2, 1), SpinOrbit(2, 0)]])

# print("Hamiltonian term representation:")
# print(f"fermionTerm0: {fermion_term_0}")
# print(f"fermionTerm1: {fermion_term_1}")
# print(f"fermionTerm2: {fermion_term_2}")

# fermion_term_0_rev = FermionHamiltonian([s.to_int() for s in spin_orbitals_0].reverse())

# print(f"Hermitian fermion term with reversed spin-orbital indices:")
# print(f"Original term                      : {fermion_term_0}")
# print(f"Reversed spin-orbital sequence term: {fermion_term_0_rev}")

# hamiltonian = FermionHamiltonian()

# hamiltonian.add(fermion_term_0, coefficient)
# hamiltonian.add(fermion_term_0_rev, 0.123)
# hamiltonian.add(fermion_term_1, 0.123)
# hamiltonian.add(fermion_term_2, 0.456)

# print("Hamiltonian representation:")
# print(hamiltonian)

# # hopping coefficient
# t = 0.5
# # repulsion coefficient
# u = 1.0
# # number of sites
# nSites = 5

# hubbard = FermionHamiltonian()

