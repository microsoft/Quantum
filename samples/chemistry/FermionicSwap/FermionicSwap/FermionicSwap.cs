// Copyright Battelle Memorial Institute 2022. All rights reserved.

using System.Linq;
using System.Collections.Immutable;

using Microsoft.Quantum.Chemistry.Fermion;
using Microsoft.Quantum.Chemistry.LadderOperators;
using Microsoft.Quantum.Chemistry;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Chemistry.JordanWigner;
using Microsoft.Quantum.Chemistry.QSharpFormat;
using static System.Linq.Enumerable;

namespace FermionicSwap
{

    using FermionOperator = LadderOperator<int>;
    using SwapLayer = List<(int,int)>;
    using OperatorLayer = List<(HermitianFermionTerm,DoubleCoeff)>;
    using OperatorNetwork = List<List<(HermitianFermionTerm,DoubleCoeff)>>;

    public class SwapNetwork : List<List<(int,int)>>
    {
        public QArray<QArray<(Int64,Int64)>> ToQSharpFormat() {
            return new QArray<QArray<(Int64,Int64)>>(this.Select(item => new QArray<(Int64,Int64)>(item.Select(t=> ((Int64)t.Item1,(Int64)t.Item2)).ToArray()))
                                              .ToArray());
        }
    }
    public class TermsDictionaryComparer : IEqualityComparer<ImmutableArray<int>>
    {
        public bool Equals(ImmutableArray<int> x, ImmutableArray<int> y)
        {
            return x!.SequenceEqual(y!);
        }

        public int GetHashCode(ImmutableArray<int> obj)
        {
            return obj.Aggregate(0, (ob1,ob2) => HashCode.Combine(ob1,ob2));
        }
    }

    public class TermsDictionary : Dictionary<ImmutableArray<int>, List<(HermitianFermionTerm,DoubleCoeff)>> {
        public TermsDictionary() : base(new TermsDictionaryComparer {}) {}
    }

    public static class FSTools {
        // fixme: What is the naming convention for a library that includes a
        // single static class?

        /// # Summary
        /// Returns the first swap layer of the swap network that takes
        /// elements of startOrder to desiredPositions
        ///
        /// # Input
        /// ## startOrder
        /// A position-indexed array indicating the index of the site orbital corresponding to each position.
        /// ## desiredPositions
        /// A map from orbital sites to desired final positions
        /// ## evenParity
        /// True if this layer should consist of even-odd swaps, false if odd-even swaps.
        ///
        /// # Output
        /// A tuple (nextOrder, layer) consisting of
        /// ## nextOrder
        /// A position indexed array indicating site orbital positioning after the swap layer is applied 
        /// ## layer
        /// A list of mutually disjoint (n,n+1) transpositions.
        private static (int[],SwapLayer) EvenOddSwapLayer(int[] startOrder, Dictionary<int,int> desiredPositions, bool evenParity) {

            int start = evenParity?0:1;
            var newOrder = startOrder.ToArray();
            var swaps = new SwapLayer();

            for(int i=start;i<startOrder.Length-1; i+=2) {
                if (desiredPositions[startOrder[i]] < desiredPositions[startOrder[i+1]]) {
                    newOrder[i] = startOrder[i];
                    newOrder[i+1] = startOrder[i+1];
                } else {
                    newOrder[i+1] = startOrder[i];
                    newOrder[i] = startOrder[i+1];
                    swaps.Add((i,i+1));            
                }
            }
            return (newOrder, swaps);
        }

        /// # Summary
        /// Return a map from site orbital indices to positions, given a position-indexed array of site orbital indices.
        ///
        /// # Input
        /// ## order
        /// A position-indexed array indicating the index of the site orbital corresponding to each position.
        ///
        /// # Output
        /// A map from site orbital indices to position indices.
        public static Dictionary<int,int> PositionDictionary(int[] order) {
            var desiredPositions = new Dictionary<int,int>();
                for (int i = 0; i < order.Length; i++)
                {
                    desiredPositions[order[i]] = i;
                }
            return desiredPositions;
        
        }

        /// # Summary
        /// Return a network of swaps that converts an initial ordering of site
        /// orbitals to the desired final ordering, by implementing an even-odd
        /// sort algorithm.
        ///
        /// Even-odd sort produces a network with minimal swaps and at most one
        /// more than minimal circuit depth. A greedy circuit-packing algorithm
        /// will eliminate the one-extra circuit depth.
        ///
        /// # Input
        /// ## startOrder
        /// A position-indexed array of site orbital indices, indicating their
        /// starting order.
        /// ## endOrder
        /// A position-indexed array of site orbital indices, indicating their
        /// desired order
        ///
        /// # Output
        /// A SwapNetwork describing layers of disjoint (n,n+1) transpositions
        /// which convert startOrder to endOrder.
        public static SwapNetwork EvenOddSwap(int[] startOrder, int[] endOrder) {
            var result = new SwapNetwork();
            var thisOrder = startOrder;

            bool atLeastOnce = false;
            bool done = false;
            bool evenParity = true;
            var desiredPositions = PositionDictionary(endOrder);
            while (!done) {
                var (nextOrder,swaps) = EvenOddSwapLayer(thisOrder, desiredPositions, evenParity);
                thisOrder = nextOrder;
                if (swaps.Count > 0) {
                    result.Add(swaps);
                    evenParity = !evenParity;
                    atLeastOnce = true;
                } else {
                    if (atLeastOnce) {
                        done = true;
                    } else {
                        atLeastOnce = true;
                        evenParity = !evenParity;
                    }

                }
            }
            return result;
        }

        /// # Summary
        /// Return a swap network suitable for evaluating a Trotter step for a
        /// one-body dense Hamiltonian. The resulting network fully reverses
        /// the order of the site-orbitals. The Trotter step can be evolved
        /// without using the last two of the swap layers, but we do not
        /// assume that optimization here.
        ///
        /// # Input
        /// ## numSites
        /// The number of site orbitals in the Hamiltonian.
        /// # Output
        /// A swap network that reverses the order of the site orbitals. 
        public static SwapNetwork OneBodyDenseNetwork(int numSites) {
            var startOrder = Range(0,numSites).ToArray();
            var endOrder = startOrder.Select(x => numSites - x-1).ToArray();
            return EvenOddSwap(startOrder, endOrder);
        }

        private static List<int> Interleave(List<int> first, List<int> second) {
            var result = new List<int>() {};
            for (int i = 0; i < Math.Max(first.Count(), second.Count()); i++) {
                if (i < first.Count()) {
                    result.Add(first[i]);
                }
                if (i < second.Count()) {
                    result.Add(second[i]);
                }
            }
            return result;
        }

        private static int JWIndex (int m, int n, int numM, int numN) {
            return numN * m + n;
        }

        /// # Summary
        /// Return an efficient swap network for a two-dimensional spinless
        /// Hubbard model Hamiltiltonian, using the method
        /// [described here](https://arxiv.org/abs/2001.08324).

        /// # Input
        /// ## numM
        /// The number of rows in the Hamiltonian interaction grid.
        /// ## numM
        /// The number of columns in the Hamiltonian interaction grid.
        /// # Output
        /// The swap network.
        public static (List<int>, SwapNetwork) SpinlessTwoDHubbardNetwork(int numM, int numN) {
            var diagonals = new List<List<int>>() {};
            var startOrder = new List<int>() {};
            var endOrder = new List<int>() {};
            if (numM > 1 && numN > 1) {
                // not a trivial special case
                for (int i=0; i<numM + numN - 1; i++) {
                    var minM = Math.Max(i-(numN-1),0);
                    var maxM = Math.Min(i, numM-1);
                    diagonals.Add(Range(minM, maxM-minM+1).Select(j => JWIndex(j,i-j,numM,numN)).ToList());
                }
                // iterate over pairs of the numM+numN-1 diagonals
                for (int i=0; 2*i < numM + numN - 1; i++) {
                    if (2*i+1 == numM + numN - 1) {
                        // last "pair" of diagonals, only contains one diagonal, of length 1
                        startOrder.AddRange(diagonals[2*i]);
                    } else {
                        // interleave the pair of diagonals, greater diagonal first
                        // until we reach the corner at the last column, then
                        // lesser diagonal first.
                        if (2*i+1 < numN) {
                            startOrder.AddRange(Interleave(diagonals[2*i+1], diagonals[2*i]));
                        } else {
                            startOrder.AddRange(Interleave(diagonals[2*i], diagonals[2*i+1]));
                        }
                    }
                }
                // iterate over pairs of the numM+numN-1 diagonals, starting at
                // the second one.
                endOrder.AddRange(diagonals[0]);
                for (int i=0; 2*i + 1 < numM + numN -1; i++) {
                    if (2*i+2 == numM + numN-1) {
                        // last "pair" of diagonals, only contains one diagonal, of length 1
                        endOrder.AddRange(diagonals[2*i+1]);
                    } else {
                        // interleave the pair of diagonals, greater diagonal first
                        // until we reach the corner at the last column, then
                        // lesser diagonal first.
                        if (2*i+2 < numN) {
                            endOrder.AddRange(Interleave(diagonals[2*i+2], diagonals[2*i+1]));
                        } else {
                            endOrder.AddRange(Interleave(diagonals[2*i+1], diagonals[2*i+2]));
                        }
                    }
                }
            } else {
                // trivial grid size, no swapping needed
                startOrder = Range(0,numM*numN).ToList();
                endOrder = Range(0,numM*numN).ToList();
            }
            //endOrder = startOrder; // delete this.
            return (startOrder, EvenOddSwap(startOrder.ToArray(),endOrder.ToArray()));
        }

        /// # Summary
        /// Return an n-body fermionic Hamiltonian term, re-indexed to be
        /// evaluated in the specified Jordan-Wigner ordering.
        ///
        /// # Input
        /// ## term
        /// A Hamiltonian term (and by implication, its Hermitian conjugate).
        /// ## actualPositions
        /// A map from site orbital indices to positions, specifying a
        /// Jordan-Wigner ordering
        ///
        /// # Output
        /// A new Hamiltonian term, with reordered indices and possibly
        /// opposite sign.
        /// 
        /// ## Note
        /// Because we return the reordered sequence as a FermionTerm, the
        /// listed order of the operators will be shuffled (and the sign
        /// adjusted) to match QDK's canonical order. Because it is a
        /// HermitionFermionTerm, the reordered sequence gets replaced with its
        /// adjoint when that results in lower the canonical ordering.
        public static HermitianFermionTerm ReorderedFermionTerm(HermitianFermionTerm term, Dictionary<int,int> actualPositions) {
            return new HermitianFermionTerm(term.Sequence.Select(o=>new FermionOperator(o.Type, actualPositions[o.Index])),
                            term.Coefficient);
        }

        /// # Summary
        /// Return a plan which Q# can use to evaluate a Trotter step for a
        /// given fermionic swap network, evolving Jordan-Wigner-reordered
        /// terms between swap layers, as they become local.
        ///
        /// # Input
        /// ## H
        /// A Hamiltonian.
        /// ## swapNetwork
        /// The network of swaps to be applied.
        /// ## startOrder
        /// A position-indexed array of site orbital positions, indicating
        /// the Jordan-Wigner ordering prior to any swaps being performed.
        ///
        /// # Output
        /// A tuple (network, endOrder), consisting of the following:
        /// ## network
        /// A list, one layer inter than swapNetwork, containing the local
        /// operators to evaluate between each swap layer. Operators are
        /// ordered so that a greedy circuit-packing algorithm will produce
        /// a reasonably low-depth circuit.
        /// ## endOrder
        /// A position-indexed list of site orbital indices, indicating the
        /// Jordan-Wigner ordering after all swaps are performed. 
        public static (OperatorNetwork, int[] ) TrotterStepData(
            FermionHamiltonian H,
            SwapNetwork swapNetwork,
            int[] startOrder
            )
        {
            var opNetwork = new OperatorNetwork {};
            var endOrder = startOrder.ToArray();
            var terms = new TermsDictionary();
            foreach (var (termType, termList) in H.Terms) {
                foreach (var (term,termValue) in termList) {
                    var termSites = ImmutableArray.Create(
                        term.Sequence.OrderBy(o => o.Index).Select(o => o.Index).Distinct().ToArray()
                    );
                    if (!terms.ContainsKey(termSites)) {
                        terms[termSites] = new OperatorLayer {};
                    }
                    terms[termSites].Add((term,termValue));
                }
            }

            opNetwork.Add(ProcessNetworkLayer(terms, endOrder));
            // Apply each swap layer to the ordering and add layer interactions
            foreach (var layer in swapNetwork) {
                foreach (var (oldpos,newpos) in layer) {
                    (endOrder[oldpos], endOrder[newpos]) = (endOrder[newpos], endOrder[oldpos]);
                }
                opNetwork.Add(ProcessNetworkLayer(terms, endOrder));
            }
            return (opNetwork, endOrder);
        }

        /// # Summary
        /// Return a layer of operators for a network, updating the dictionary
        /// of already-applied terms.
        ///
        /// # Input
        /// ## termDict
        /// A map from ordered indexed lists to lists of unapplied terms having
        /// those indices.
        /// ## order
        /// A position-indexed array of site orbital indices, indicating the
        /// current Jordan-Wigner ordering.
        ///
        /// # Output
        /// A list of local HermetianFermionTerms to evaluate, expressed in
        /// the local Jordan-Wigner ordering.
        ///
        /// # Side effects
        /// Terms are removed from termDict as they are applied.
        public static OperatorLayer ProcessNetworkLayer(
            TermsDictionary termDict,
            int[] order)
        {
            var result = new OperatorLayer {};
            bool productive = true;
            while (productive) {
                productive = false;
                var start = 0;
                var end = 1;
                while (start < order.Count()) {
                    while (end <= order.Count()) {
                        var key = ImmutableArray.Create(order[start..end].OrderBy(o=>o).Distinct().ToArray());
                        if (termDict.ContainsKey(key)) {
                            var (term,coeff) = termDict[key][0];
                            result.Add((ReorderedFermionTerm(term, PositionDictionary(order[0..end])), coeff));
                            termDict[key].RemoveAt(0);
                            if (termDict[key].Count() == 0) {
                                termDict.Remove(key);
                            }
                            productive = true;
                            // find evolutions that can occur in parallel with this one,
                            // then end the layer.
                            start = end; 
                        }
                        end++;
                    }
                    start++;
                    end = start + 1;
                }
            }
            return result;
        }

        // using OperatorNetwork = List<List<HermitianFermionTerm>>;

        /// # Summary
        /// Construct an array of arrays of Q# processable Pauli Hamiltonians from the swap operator network.
        ///
        /// # Input
        /// ## network
        /// The layer-sorted list of localized evolutions that occur between swap layers
        /// ## gatherTerms=false
        /// If true, an interaction layer consists of a list containing a
        ///   single Hamiltonian containing all terms.
        /// If false, an interaction layer consists of a list of Hamiltonians,
        ///   one for each term.
        ///
        /// # Output
        /// A QArray of QArrays of Pauli Hamiltonians in Q# format. Each inner
        /// QArray represents a single interaction layer.
        /// Q# format for an individual PauliHamiltonian is of type
        /// (Double, Int64, JWOptimizedHTerms)
        /// and consists of
        ///   energyOffset: The energy offset (coefficient of the identity summand)
        ///   nSpinOrbitals: number of spin orbitals
        ///   terms: QArrays of Hamlitonian terms, organized by term "shape"

        public static QArray<QArray<JWOptimizedHTerms>> ToQSharpFormat(OperatorNetwork network, bool gatherLayer = false) {
            var result = new List<QArray<JWOptimizedHTerms>>();
            var terms = new JWOptimizedHTerms();
            foreach (var layer in network) {
                var resultLayer = new List<JWOptimizedHTerms>();
                var H = new FermionHamiltonian();
                foreach (var (term,coeff) in layer) {
                    H.Add(term,coeff);
                    if (!gatherLayer) {
                        (_, _, terms) = H.ToPauliHamiltonian().ToQSharpFormat();
                        resultLayer.Add(terms);
                        H = new FermionHamiltonian();
                    }
                }
                if (H.Terms.Count > 0) {
                    (_, _, terms) = H.ToPauliHamiltonian().ToQSharpFormat();
                } else {
                    terms = new JWOptimizedHTerms();
                }
                resultLayer.Add(terms);
                result.Add(new QArray<JWOptimizedHTerms>(resultLayer));
            }
            return new QArray<QArray<JWOptimizedHTerms>>(result);
        }
    }
}