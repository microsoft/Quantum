// Copyright Battelle Memorial Institute 2022. All rights reserved.

using Microsoft.Quantum.Chemistry.Fermion;
using Microsoft.Quantum.Chemistry.LadderOperators;
using Microsoft.Quantum.Chemistry;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Chemistry.JordanWigner;
using static FermionicSwap.FSTools;
using Microsoft.Quantum.Chemistry.QSharpFormat;
using static FermionicSwap.SwapNetwork;
using System.Linq;
using System.Collections.Immutable;
using System;

namespace FermionicSwap.Tests
{

    using SwapLayer = List<(int,int)>;
    using OperatorLayer = List<(HermitianFermionTerm, DoubleCoeff)>;
    using OperatorNetwork = List<List<(HermitianFermionTerm, DoubleCoeff)>>;

    public class TestFermionicSwap
{

    [Theory]
    [MemberData(nameof(Data))]
    public void TestEvenOddSwap(int[] startOrder, int[] endOrder, SwapNetwork swapNetwork)
    {
        var result = FSTools.EvenOddSwap(startOrder, endOrder);
        Assert.True(result.Count == swapNetwork.Count, $"Need swap layers {LayersString(swapNetwork)}, but got {LayersString(result)}.");
        // for each swap layer, check that the list of swaps matches the test list
        foreach (var (first,second) in result.Zip(swapNetwork, (f,s)=> (f,s))) {
            Assert.True(first.SequenceEqual(second), $"Swap network {LayersString(result)} should be {LayersString(swapNetwork)}.");
        }
    }
 
    public static IEnumerable<object[]> Data => new List<object[]>
    {
        // empty layer
        new object[] { new int[] {}, new int[] {}, new SwapNetwork {} },
        // trivial swapping
        new object[] { new int[] {0,1}, new int[] {0,1}, new SwapNetwork {} },
        // nontrivial
        new object[] { new int[] {1,0}, new int[] {0,1}, new SwapNetwork {new SwapLayer {(0,1)}}},
        // site numbering does not start from zero
        new object[] { new int[] {1,2}, new int[] {2,1}, new SwapNetwork {new SwapLayer {(0,1)}}},
        // three items, trivial swapping
        new object[] { new int[] {0,1,2}, new int[] {0,1,2}, new SwapNetwork {}},
        // four items, trivial swapping
        new object[] { new int[] {0,1,2,3}, new int[] {0,1,2,3}, new SwapNetwork {}},
        // five items, trivial swapping
        new object[] { new int[] {0,1,2,3,4}, new int[] {0,1,2,3,4}, new SwapNetwork {}},
        // three items, nontrivial swapping
        new object[] { new int[] {0,1,2}, new int[] {2,1,0}, new SwapNetwork {
            new SwapLayer {(0,1)},
            new SwapLayer {(1,2)},
            new SwapLayer {(0,1)}
            }
        },
        // three items, no (even) swaps in initial swap layer
        new object[] { new int[] {0,1,2}, new int[] {0,2,1}, new SwapNetwork {new SwapLayer {(1,2)}}},
        // 7 items, a single item moves in each layer
        new object[] { new int[] {0,1,2,3,4,5,6}, new int[] {6,0,1,2,3,4,5}, new SwapNetwork {
            new SwapLayer {(5,6)},
            new SwapLayer {(4,5)},
            new SwapLayer {(3,4)}, new SwapLayer {(2,3)},
            new SwapLayer {(1,2)}, new SwapLayer {(0,1)},
            }},
        // odd larger number of items, full reverse
        new object[] { new int[] {0,1,2,3,4,5,6}, new int[] {6,5,4,3,2,1,0}, new SwapNetwork {
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4),(5,6)},
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4),(5,6)},
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4),(5,6)},
            new SwapLayer {(0,1),(2,3),(4,5)},
        }},
        // even larger number of items, full reverse
        new object[] { new int[] {0,1,2,3,4,5}, new int[] {5,4,3,2,1,0}, new SwapNetwork {
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4)},
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4)},
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4)},
        }}
    };

    [Theory]
    [MemberData(nameof(OneBodyDenseNetworkData))]
    public void TestOneBodyDenseNetwork(int numSites, SwapNetwork swapNetwork)
    {
        var result = FSTools.OneBodyDenseNetwork(numSites);
        Assert.True(result.Count == swapNetwork.Count, $"Need swap layers {LayersString(swapNetwork)}, but got {LayersString(result)}.");
        // for each swap layer, check that the list of swaps matches the test list
        foreach (var (first,second) in result.Zip(swapNetwork, (f,s)=> (f,s))) {
            Assert.True(first.SequenceEqual(second), $"Swap network {LayersString(result)} should be {LayersString(swapNetwork)}.");
        }
    }
    public static IEnumerable<object[]> OneBodyDenseNetworkData => new List<object[]>
    {
        // Small one body swap networks of various sizes. Small, larger odd and larger even.
        new object[] {0, new SwapNetwork {}},
        new object[] {1, new SwapNetwork {}},
        new object[] {2, new SwapNetwork {new SwapLayer {(0,1)}}},
        new object[] {3, new SwapNetwork {new SwapLayer {(0,1)}, new SwapLayer {(1,2)}, new SwapLayer {(0,1)}}},
        new object[] {6, new SwapNetwork {
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4)},
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4)},
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4)},
        }},
        new object[] {7, new SwapNetwork {
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4),(5,6)},
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4),(5,6)},
            new SwapLayer {(0,1),(2,3),(4,5)},
            new SwapLayer {(1,2),(3,4),(5,6)},
            new SwapLayer {(0,1),(2,3),(4,5)},
        }},
    };

[Theory]
    [MemberData(nameof(SpinlessTwoDHubbardNetworkData))]
    public void TestSpinlessTwoDHubbardNetwork(int numM, int numN, int[] correctStartOrder, SwapNetwork swapNetwork)
    {
        var (startOrder, result) = FSTools.SpinlessTwoDHubbardNetwork(numM, numN);
        var actualLayerCount = result.Count;
        Assert.Equal(startOrder, correctStartOrder.ToList());
        Assert.True(actualLayerCount == swapNetwork.Count,
            $"Got {actualLayerCount} swap layers, but needed {swapNetwork.Count}."
            );
        // for each swap layer, check that the list of swaps matches the test list
        foreach (var (first,second) in result.Zip(swapNetwork, (f,s)=> (f,s))) {
            Assert.True(first.SequenceEqual(second), $"Swap network {LayersString(result)} should be {LayersString(swapNetwork)}.");
        }
    }
    public static IEnumerable<object[]> SpinlessTwoDHubbardNetworkData => new List<object[]>
    {
        // Small 2D Hubbard swap networks.
        new object[] {1, 1, new int[]{0}, new SwapNetwork {}},
        new object[] {1, 2, new int[] {0,1}, new SwapNetwork {}},
        new object[] {2, 1, new int[] {0,1}, new SwapNetwork {}},
        // 1 0 2 3 -> 0 1 3 2
        new object[] {2, 2, new int[] {1,0,2,3},
                      new SwapNetwork {new SwapLayer{(0,1),(2,3)}}},
        // 1 0 2 3 5 4 -> 0 1 3 2 4 5
        new object[] {3, 2, new int[] {1,0,2,3,5,4},
                      new SwapNetwork {new SwapLayer{(0,1),(2,3),(4,5)}}},
        // 1 0 3 2 5 4 -> 0 2 1 4 3 5
        new object[] {2,3, new int[] {1,0,3,2,5,4},
                      new SwapNetwork {new SwapLayer{(0,1),(2,3),(4,5)},
                      new SwapLayer{(1,2), (3,4)}}},
        // 1 0 3 2 5 4 7 6 8 -> 0 2 1 4 3 6 5 8 7
        new object[] {3, 3, new int[] {1,0,3,2,5,4,7,6,8},
                      new SwapNetwork {new SwapLayer{(0,1),(2,3),(4,5),(6,7)},
                      new SwapLayer{(1,2),(3,4),(5,6),(7,8)}}},
        // 1 0 4 3 2 6 5 9 8 12 7 11 10 14 13 15 ->
        // 0 2 1 5 4 8 3 7 6 10 9 13 12 11 15 14
        new object[] {4, 4, new int[]{1, 0, 4, 3, 2, 6, 5, 9, 8, 12, 7, 11, 10, 14, 13, 15},
            EvenOddSwap(
            new int[]{1, 0, 4, 3, 2, 6, 5, 9, 8, 12, 7, 11, 10, 14, 13, 15},
            new int[]{0, 2, 1, 5, 4, 8, 3, 7, 6, 10, 9, 13, 12, 11, 15, 14})}
    };

    [Theory]
    [MemberData(nameof(ReorderedFermionTermData))]
    public void TestReorderedFermionTerm(HermitianFermionTerm term,
                                        Dictionary<int,int> desiredOrder,
                                        List<int> correctTerm,
                                        int coefficient) {
        var newTerm = ReorderedFermionTerm(term, desiredOrder);
        var result = newTerm.Sequence.Select(o => o.Index);
        var resultString = String.Join(", ", result);
        Assert.True(result.SequenceEqual(correctTerm), $"Incorrect order {resultString}.");
        Assert.Equal(coefficient, newTerm.Coefficient);
    }

    // Note: the reordered terms are returned in QDK's canonical ladder operator order.
    public static IEnumerable<object[]> ReorderedFermionTermData => new List<object[]>
    {
        // Leave a correctly ordered object alone.
        new object[] {
            new HermitianFermionTerm(new int[] {0,1}),
            PositionDictionary(new int[] {0,1}),
            new List<int> {0,1},
            1
            },
        new object[] {
            new HermitianFermionTerm(new int[] {0,1,3,2}),
            PositionDictionary(new int[] {0,1,2,3}),
            new List<int> {0,1,3,2},
            1
            },
        new object[] {
            new HermitianFermionTerm(new int[] {0,5,6,4}),
            PositionDictionary(new int[] {0,1,2,3,4,5,6}),
            new List<int> {0,5,6,4},
            1
            },

        // Permute to new positions correctly in the absence of canonical reordering
        new object[] {
            new HermitianFermionTerm(new int[] {0,1}),
            PositionDictionary(new int[] {1,0}),
            // Hermitian reordering occurs here
            new List<int> {0,1},
            1
            },
        new object[] {
            new HermitianFermionTerm(new int[] {1,3,2,0}),
            PositionDictionary(new int[] {0,1,3,2}),
            new List<int> {0,3,2,1},
            1
            },
        new object[] {
            new HermitianFermionTerm(new int[] {2,4,3,1}),
            PositionDictionary(new int[] {0,1,2,4,3}),
            new List<int> {1,4,3,2},
            1
            },
        // Permute to new positions with pre/post canonical reordering
        // differing by even/even permutations from given ordering
        new object[] {
            new HermitianFermionTerm(new int[] {0,1,2,3,4,5,6,7}),
            PositionDictionary(new int[] {1,0,3,2,7,6,5,4}),
            new List<int> {0,1,2,3,7,6,5,4},
            1
            },
        // Same, but even/odd        
        new object[] {
            new HermitianFermionTerm(new int[] {0,1,2,3,4,5,6,7}),
            PositionDictionary(new int[] {0,1,3,2,7,6,5,4}),
            new List<int> {0,1,2,3,7,6,5,4},
            -1
            },       
        // Same, but odd/even        
        new object[] {
            new HermitianFermionTerm(new int[] {0,1,2,3,4,5,7,6}),
            PositionDictionary(new int[] {1,0,3,2,7,6,5,4}),
            new List<int> {0,1,2,3,7,6,5,4},
            -1
            },
        // Same, but odd/odd        
        new object[] {
            new HermitianFermionTerm(new int[] {0,1,2,3,4,5,7,6}),
            PositionDictionary(new int[] {0,1,3,2,7,6,5,4}),
            new List<int> {0,1,2,3,7,6,5,4},
            1
            },
    };

    [Theory]
    [MemberData(nameof(ProcessNetworkLayerData))]
    public void TestProcessNetworkLayer(
            TermsDictionary termDict,
            int[] order,
            OperatorLayer correct)
    {
        var result = ProcessNetworkLayer(termDict, order);
        Assert.True(result.Count() == correct.Count(), $"Result has {result.Count()} elements but correct result has {correct.Count()}");
        foreach (var (r,c) in result.Zip(correct)) {
            Assert.True(r == c, $"{r} does not equal {c}.");
        }
    }

    // Note: the reordered terms are returned in QDK's canonical ladder operator order.
    public static IEnumerable<object[]> ProcessNetworkLayerData => new List<object[]>
    {
        // Produce no operators if there are no terms.
        new object[] {
            new TermsDictionary(),
            new int[] {0,1,2,3},
            new OperatorLayer {}
        },
        // Produce an operator from a term
        new object[] {
            new TermsDictionary() {{ImmutableArray.Create(new int[] {0,1}), new OperatorLayer {
                (new HermitianFermionTerm(new int[] {0,1}),3.0)
            }}},
            new int[] {0,1},
            new OperatorLayer{(new HermitianFermionTerm(new int[] {0,1}),3.0)}
        },
        // Produce an operator from a misordered term
        new object[] {
            new TermsDictionary() {{ImmutableArray.Create(new int[] {0,1}), new OperatorLayer {
                (new HermitianFermionTerm(new int[] {0,1}),3.0)
            }}},
            new int[] {0,1},
            new OperatorLayer{(new HermitianFermionTerm(new int[] {0,1}),3.0)}
        },
        // Apply the greedy algorithm to produce multiple operators
        new object[] {
            new TermsDictionary() {
                {ImmutableArray.Create(new int[] {0,1}), new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {0,1}),1.0)
                }},
                {ImmutableArray.Create(new int[] {3,4}), new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {3,4}),1.0)
                }},

            },
            new int[] {0,1,2,3,4},
            new OperatorLayer{
                (new HermitianFermionTerm(new int[] {0,1}),1.0),
                (new HermitianFermionTerm(new int[] {3,4}),1.0)
            }
        },
        // Process multiple operators with the same indices
        // double check time application
        new object[] {
            new TermsDictionary() {
                {ImmutableArray.Create(new int[] {0,1}), new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {0,1}),1.0),
                    (new HermitianFermionTerm(new int[] {0,1,1,0}),2.0)
                }},
                {ImmutableArray.Create(new int[] {3,4}), new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {3,4}),3.0)
                }},

            },
            new int[] {0,1,2,3,4},
            new OperatorLayer{
                (new HermitianFermionTerm(new int[] {0,1}),1.0),
                (new HermitianFermionTerm(new int[] {3,4}),3.0),
                (new HermitianFermionTerm(new int[] {0,1,1,0}),2.0)
            }
        },
        // Handle operator overlap correctly
        new object[] {
            new TermsDictionary() {
                {ImmutableArray.Create(new int[] {0,1}), new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {0,1}),1.0),
                    (new HermitianFermionTerm(new int[] {0,1,1,0}),1.0)
                }},
                {ImmutableArray.Create(new int[] {1,2,3,4}), new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {2,4,3,1}),1.0)
                }},
                {ImmutableArray.Create(new int[] {3,4}), new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {3,4}),1.0)
                }},

            },
            new int[] {0,1,2,3,4},
            new OperatorLayer{
                (new HermitianFermionTerm(new int[] {0,1}),1.0),
                (new HermitianFermionTerm(new int[] {3,4}),1.0),
                (new HermitianFermionTerm(new int[] {0,1,1,0}),1.0),
                (new HermitianFermionTerm(new int[] {2,4,3,1}),1.0)
            }
        },
        // Correctly reorder the terms
        new object[] {
            new TermsDictionary() {
                {ImmutableArray.Create(new int[] {0,1}), new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {0,1}),1.0),
                    (new HermitianFermionTerm(new int[] {0,1,1,0}),1.0)
                }},
                {ImmutableArray.Create(new int[] {1,2,3,4}), new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {2,4,3,1}),1.0)
                }},
                {ImmutableArray.Create(new int[] {3,4}), new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {3,4}),1.0)
                }},

            },
            new int[] {4,3,2,1,0},
            new OperatorLayer{
                (new HermitianFermionTerm(new int[] {1,0}),1.0), // 3,4
                (new HermitianFermionTerm(new int[] {4,3}),1.0), // 0,1
                (new HermitianFermionTerm(new int[] {0,2,3,1}),1.0), // 2,4,3,1
                (new HermitianFermionTerm(new int[] {4,3,3,4}),1.0), // 0,1,1,0
            }
        }

    };

    [Theory]
    [MemberData(nameof(TrotterStepDataData))]
    public void TestTrotterStepData(
            FermionHamiltonian H,
            SwapNetwork swapNetwork,
            int[] startOrder,
            OperatorNetwork correctNetwork,
            int[] correctOrder
            )
    {
        var (operatorNetwork, endOrder) = TrotterStepData(H, swapNetwork, startOrder);
        Assert.True(endOrder.SequenceEqual(correctOrder),
            $"Resulting order {String.Join(", ", endOrder)} differs from correct order {String.Join(", ", correctOrder.Select(o=>o.ToString()))}.");
        Assert.True(operatorNetwork.Count() == swapNetwork.Count() + 1,
            $"Resulting operator network has {operatorNetwork.Count()} layers instead of {swapNetwork.Count()}.");
        foreach (var (r,c) in operatorNetwork.Zip(correctNetwork)) {
            Assert.True(r.SequenceEqual(c), $"Resulting layer {String.Join(", ", r)} differs from correct layer {String.Join(", ", c)}.");
        }
    }

    // Note: the reordered terms are returned in QDK's canonical ladder operator order.
    public static IEnumerable<object[]> TrotterStepDataData() {
        var result = new List<object[]> {};

        // An empty Hamiltonian and swap network produce an empty operator network.
        var H = new FermionHamiltonian {};
        var swapNetwork = new SwapNetwork {};
        var startOrder = new int[]{};
        var correctNetwork = new OperatorNetwork {};
        int[] correctOrder = startOrder.ToArray();
        result.Add(new object[] {H, swapNetwork, startOrder, correctNetwork, correctOrder});

        // An empty Hamiltonian and any swap network produce an empty operator network.
        H = new FermionHamiltonian {};
        swapNetwork = OneBodyDenseNetwork(3);
        startOrder = new int[] {0,1,2};
        correctNetwork = new OperatorNetwork {};
        correctOrder = startOrder.Reverse().ToArray();
        result.Add(new object[] {H, swapNetwork, startOrder, correctNetwork, correctOrder});

        // correct networks for some dense hopping term hamiltonians
        var correctNetworks = new List<OperatorNetwork> {
            // 3 sites
            new OperatorNetwork {
                new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {0,1}), 1.0),
                    (new HermitianFermionTerm(new int[] {1,2}), 1.0)
                },
                new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {1,2}),1.0)
                },
                new OperatorLayer {}
            },
            // 4 sites
            new OperatorNetwork {
                new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {0,1}), 1.0),
                    (new HermitianFermionTerm(new int[] {2,3}), 1.0),
                    (new HermitianFermionTerm(new int[] {1,2}), 1.0)
                },
                new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {1,2}), 1.0),
                },
                new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {0,1}), 1.0),
                    (new HermitianFermionTerm(new int[] {2,3}), 1.0),
                },
                new OperatorLayer {}
            },
            // 5 sites
            new OperatorNetwork {
                new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {0,1}), 1.0),
                    (new HermitianFermionTerm(new int[] {2,3}), 1.0),
                    (new HermitianFermionTerm(new int[] {1,2}), 1.0),
                    (new HermitianFermionTerm(new int[] {3,4}), 1.0)
                },
                new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {1,2}), 1.0),
                    (new HermitianFermionTerm(new int[] {3,4}), 1.0),
                },
                new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {0,1}), 1.0),
                    (new HermitianFermionTerm(new int[] {2,3}), 1.0),
                },
                new OperatorLayer {
                    (new HermitianFermionTerm(new int[] {1,2}), 1.0),
                    (new HermitianFermionTerm(new int[] {3,4}), 1.0),
                },
                new OperatorLayer {}
            }
        };

        // Dense Hopping terms on 3,4,5 site orbitals
        int numSites = 3;
        for (; numSites < 6; numSites++) {
            H = new FermionHamiltonian {};
            for (int i = 0; i < numSites; i++) {
                for (int j = i+1; j < numSites; j++) {
                    H.Add(new HermitianFermionTerm(new int[] {i, j}), 1.0);
                }
            }
            swapNetwork = OneBodyDenseNetwork(numSites);
            startOrder = Enumerable.Range(0,numSites).ToArray();
            correctOrder = startOrder.Reverse().ToArray();
            result.Add(new object[] {H, swapNetwork, startOrder, correctNetworks[numSites-3], correctOrder});
        }

        // 5 sites with self-interactions
        numSites = 5;
        H = new FermionHamiltonian {};
        for (int i = 0; i < numSites; i++) {
            for (int j = i+1; j < numSites; j++) {
                H.Add(new HermitianFermionTerm(new int[] {i, j}), 1.0);
            }
            H.Add(new HermitianFermionTerm(new int[] {i,i}), (Double)(i+1));
        }
        swapNetwork = OneBodyDenseNetwork(numSites);
        startOrder = Enumerable.Range(0,numSites).ToArray();
        correctNetwork = new OperatorNetwork {
            new OperatorLayer {
                (new HermitianFermionTerm(new int[] {0,0}), 1.0),
                (new HermitianFermionTerm(new int[] {1,1}), 2.0),
                (new HermitianFermionTerm(new int[] {2,2}), 3.0),
                (new HermitianFermionTerm(new int[] {3,3}), 4.0),
                (new HermitianFermionTerm(new int[] {4,4}), 5.0),
                (new HermitianFermionTerm(new int[] {0,1}), 1.0),
                (new HermitianFermionTerm(new int[] {2,3}), 1.0),
                (new HermitianFermionTerm(new int[] {1,2}), 1.0),
                (new HermitianFermionTerm(new int[] {3,4}), 1.0)
            },
            new OperatorLayer {
                (new HermitianFermionTerm(new int[] {1,2}), 1.0),
                (new HermitianFermionTerm(new int[] {3,4}), 1.0),
            },
            new OperatorLayer {
                (new HermitianFermionTerm(new int[] {0,1}), 1.0),
                (new HermitianFermionTerm(new int[] {2,3}), 1.0),
            },
            new OperatorLayer {
                (new HermitianFermionTerm(new int[] {1,2}), 1.0),
                (new HermitianFermionTerm(new int[] {3,4}), 1.0),
            },
            new OperatorLayer {}
        };
        correctOrder = startOrder.Reverse().ToArray();
        result.Add(new object[] {H, swapNetwork, startOrder, correctNetwork, correctOrder});

        // verify that weights transfer correctly
        H = new FermionHamiltonian {};
        numSites = 5;
        for (int i = 0; i < numSites; i++) {
            for (int j = i+1; j < numSites; j++) {
                H.Add(new HermitianFermionTerm(new int[] {i, j}), (double)(10*i+j));
            }
        }
        swapNetwork = OneBodyDenseNetwork(numSites);
        startOrder = Enumerable.Range(0,numSites).ToArray();
        correctOrder = startOrder.Reverse().ToArray();
        correctNetwork = new OperatorNetwork {
            new OperatorLayer {
                (new HermitianFermionTerm(new int[] {0,1}), 1.0),
                (new HermitianFermionTerm(new int[] {2,3}), 23.0),
                (new HermitianFermionTerm(new int[] {1,2}), 12.0),
                (new HermitianFermionTerm(new int[] {3,4}), 34.0)
            },
            // order 10324
            new OperatorLayer {
                (new HermitianFermionTerm(new int[] {1,2}), 3.0),
                (new HermitianFermionTerm(new int[] {3,4}), 24.0),
            },
            // order 13042
            new OperatorLayer {
                (new HermitianFermionTerm(new int[] {0,1}), 13.0),
                (new HermitianFermionTerm(new int[] {2,3}), 4.0),
            },
            //order 31402
            new OperatorLayer {
                (new HermitianFermionTerm(new int[] {1,2}), 14.0),
                (new HermitianFermionTerm(new int[] {3,4}), 2.0),
            },
            //order 34120
            new OperatorLayer {}
            //order 43210
        };

        result.Add(new object[] {H, swapNetwork, startOrder, correctNetwork, correctOrder});

        return result;
    }

    // Check the operation of the following functions:
    //     ToQSharpFormat,
    //     FermionicSwapTrotterStep (qsharp),
    //     FixedOrderFermionicSwapTrotterStep (qsharp),
    // by constructing a Hamiltonian for a Trotter step and checking for
    // equality with the corresponding JordanWigner trotter step. Since
    // the two methods do not agree on the order in which terms are
    // evaluated, which results in unequal Trotter steps in general, this
    // test uses Hamiltonians consisting of single PQ terms.
    [Theory]
    [MemberData(nameof(OneTermHamiltonianData))]
    public void TestOneTermHamiltonian(
            FermionHamiltonian H,
            SwapNetwork swapNetwork,
            int[] startOrder
            )
    {
        var (opNetwork, endOrder) = TrotterStepData(H, swapNetwork, startOrder);
        //we use 32 bit ints until the point of injection into q#, which requires 64 bit ints.
        var qsharpSwapNetwork = swapNetwork.ToQSharpFormat();
        var qsharpData = ToQSharpFormat(opNetwork, false);
        var (_,_,qsharpHamiltonian) = H.ToPauliHamiltonian().ToQSharpFormat();

        Assert.Equal(qsharpSwapNetwork.Length+1, qsharpData.Length);
        using (var qsim = new QuantumSimulator())
        {
            SwapNetworkOneSummandTestOp.Run(qsim, qsharpSwapNetwork, qsharpData, qsharpHamiltonian,
                                    (long)startOrder.Length)
                             .Wait();
        }
    }

    public static IEnumerable<object[]> OneTermHamiltonianData() {
        var result = new List<object[]> {};
        var numSites = 5;
        for (int i = 0; i < numSites; i++) {
            for (int j = i+1; j < numSites; j++) {
                var H = new FermionHamiltonian {};
                H.Add(new HermitianFermionTerm(new int[] {i, j}), (double)(10*i+j));
                var swapNetwork = OneBodyDenseNetwork(numSites);
                result.Add(new object[] {H, swapNetwork, Enumerable.Range(0,numSites).ToArray()});
        }
        }
    
        return result;
    }

    [Theory]
    [MemberData(nameof(HamiltonianData))]
    public void TestHamiltonian(
        FermionHamiltonian H,
        int numSites,
        SwapNetwork swapNetwork,
        double stepSize,
        double time
    ) {
        var startOrder = Enumerable.Range(0,numSites).ToArray();
        var (opNetwork, endOrder) = TrotterStepData(H, swapNetwork, startOrder);
        //we use 32 bit ints until the point of injection into q#, which requires 64 bit ints.
        var qsharpSwapNetwork = swapNetwork.ToQSharpFormat();
        var qsharpData = ToQSharpFormat(opNetwork, false);
        var (_,_,qsharpHamiltonian) = H.ToPauliHamiltonian().ToQSharpFormat();

        Assert.Equal(qsharpSwapNetwork.Length+1, qsharpData.Length);
        using (var qsim = new QuantumSimulator())
        {
            SwapNetworkEvolutionTestOp.Run(qsim, qsharpSwapNetwork, qsharpData, qsharpHamiltonian,
                                    (long)numSites, stepSize, time)
                             .Wait();
        }        
    }

    // One term hamiltonians, similar to previous test
    public static IEnumerable<object[]> HamiltonianData() {
        var result = new List<object[]> {};
        var numSites = 5;
        for (int i = 0; i < numSites; i++) {
            for (int j = i+1; j < numSites; j++) {
                var H = new FermionHamiltonian {};
                H.Add(new HermitianFermionTerm(new int[] {i, j}), (double)(10*i+j));
                var swapNetwork = OneBodyDenseNetwork(numSites);
                var stepSize = 1;
                var time = 2;
                result.Add(new object[] {H, numSites, swapNetwork, stepSize, time});
            }
        }
        // A dense Hamiltonian
        var H2 = new FermionHamiltonian {};
        var swapNetwork2 = OneBodyDenseNetwork(numSites);
        var stepSize2 = .00002;
        var time2 = .001;
        for (int i = 0; i < numSites; i++) {
            for (int j = i+1; j < numSites; j++) {
                H2.Add(new HermitianFermionTerm(new int[] {i, j}), (double)(10*i+j));
            }
        }
        result.Add(new object[] {H2, numSites, swapNetwork2, stepSize2, time2});

    
        return result;
    }

    public string LayersString(SwapNetwork swaps) {
            var result = "{";
            var swapsOccupied = false;
            foreach (var layer in swaps) {
                if (swapsOccupied) {
                    result += ", ";
                } else {
                    result += "{";
                    swapsOccupied = true;
                }
                var layerOccupied = false;
                foreach (var (a,b) in layer) {
                    if (layerOccupied) {
                        result += ", ";
                    } else {
                        result += "{";
                        layerOccupied = true;
                    }
                    result += $"({a}, {b})";
                }
                result += "}";
            }
            result += "}";
            return result;
        }

    }
}