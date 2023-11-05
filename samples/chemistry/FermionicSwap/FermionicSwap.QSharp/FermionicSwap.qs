// Copyright Battelle Memorial Institute 2022. All rights reserved.

// Q# functions for Fermionic Swap.

// Code rationale: the code that creates swap networks uses
// dictionaries, which are not available in Q#. The eventual goal is to call
// the needed C# functions from Q#, but for now everything is driven from C#.
// These functions take a data structure produced by C# code and use it to perform
// evolution of Jordan-Wigner represented fermions using swap networks.

namespace FermionicSwap
{
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Chemistry.JordanWigner;
    open Microsoft.Quantum.Simulation;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// Swap two qubits and apply -1 phase if both are in occupied states.
    /// Effectively permutes pairwise elements in the Jordan-Wigner ordering.
    ///
    /// # Input
    /// ## a
    /// A Qubit.
    /// ## b
    /// Another Qubit. Should be adjacent to the first qubit in the Jordan-Wigner ordering.
    operation FermionicSwap(a : Qubit, b : Qubit) : Unit is Adj + Ctl {
        SWAP(a,b);
        CZ(a,b);
    }

    /// # Summary
    /// Apply a sequence of fermionic swaps.
    ///
    /// # Input
    /// ## swaps : An array of pairs of qubit indices to swap,
    /// ## qubits: The qubits encoding the state, in the Jordan-Wigner representation.
    operation FermionicSwapLayer( swaps : (Int,Int)[], qubits : Qubit[]) : Unit is Adj + Ctl {
        for (a,b) in swaps {
            FermionicSwap(qubits[a],qubits[b]);
        }
    }

    /// # Summary
    /// ## Apply Fermionic Swap Trotter steps to qubits.
    ///
    /// # Input
    /// ## generator
    /// an EvolutionGenerator which describes a Fermionic Swap Trotter step,
    /// ## trotterStepSize
    /// Time duration of a single Trotter step,
    /// ## time
    /// Total duration of evolution,
    /// ## register
    /// The qubits to be operated upon.
    ///
    /// # Remarks
    /// Changes the Jordan-Wigner ordering if evolution requires an odd number
    /// of time steps.
    operation FermionicSwapEvolveUnderGenerator(
        generator : EvolutionGenerator,
        trotterStepSize : Double,
        time : Double,
        register : Qubit[]
    ) : Unit is Adj + Ctl {
        let evolveFor = (FermionicSwapSimulationAlgorithm(trotterStepSize))!;
        evolveFor(time, generator, register);
    }

    /// # Summary
    /// Apply a single fermionic swap Trotter step.
    ///
    /// # Input
    /// ## swapNetwork
    /// The swaps to be performed. An array of arrays, one for each layer.
    /// ## localEvolutions
    /// Local evolutions to be performed between swap layers. Each evolution
    /// is a JWOptimizedHTerms object, and each local evolution layer is an
    /// array of such to keep Q# from optimizing. If Q# optimization is
    /// desired, the layer may be specified as a length one array with all
    /// evolutions combined in a single JWOptimizedHTerms object.
    /// ## time
    /// The duration of the Trotter step.
    /// ## qubits
    /// The qubits to be acted upon.
    /// 
    /// # Remarks
    /// Changes the Jordan-Wigner ordering. Applying again with layers reversed
    /// restores the original Jordan-Wigner ordering.
    operation FermionicSwapTrotterStep(
        swapNetwork : (Int,Int)[][],
        localEvolutions : JWOptimizedHTerms[][],
        time : Double,
        qubits : Qubit[]) : Unit
    {
        let nTerms = Length(qubits);
        for i in 0 .. Length(swapNetwork) {
            for ops in localEvolutions[i] {
                mutable empty = true;
                let (opa,opb,opc,opd) = ops!;
                if Length(opa) > 0 or Length(opb) > 0 or Length(opc) > 0 or Length(opd) > 0 {
                    set empty = false;
                }
                if (not empty) {
                    let generatorSystem = JordanWignerGeneratorSystem(ops);
                    let evolutionGenerator = EvolutionGenerator(JordanWignerFermionEvolutionSet(), generatorSystem);
                    TrotterStep(evolutionGenerator, 1, time)(qubits);
                }
            }
            if i < Length(swapNetwork) {
                FermionicSwapLayer(swapNetwork[i], qubits);
            }
        }
    }

    /// # Summary
    /// Internal implementation of single layer for a fermionic swap
    /// Hamiltonian evolution Trotter step.
    /// Trotterized swap network.
    ///
    /// # Input
    /// ## stepSize
    /// Duration of a Trotter step.
    /// ## time
    /// Duration of the evolution.
    /// ## generator
    /// An EvolutionGenerator.
    /// ## qubits
    /// The qubits in the system to be acted upon.
    operation FermionicSwapEvolutionImpl(
        swapNetwork : (Int,Int)[][],
        localEvolutions : JWOptimizedHTerms[][],
        generatorIndex : GeneratorIndex,
        time : Double,
        qubits : Qubit[]
    ) : Unit is Adj + Ctl{
        body (...) {
            let ((indices, _), _) = generatorIndex!;
            let index = indices[0];
            let gi = (index-1) / 2;
            if index % 2 != 0 {
                for ops in localEvolutions[gi] {
                    let (opa,opb,opc,opd) = ops!;
                    if (Length(opa) > 0 or Length(opb) > 0 or Length(opc) > 0 or Length(opd) > 0) {
                        let generatorSystem = JordanWignerGeneratorSystem(ops);
                        let evolutionGenerator = EvolutionGenerator(JordanWignerFermionEvolutionSet(), generatorSystem);
                        TrotterStep(evolutionGenerator, 1, time)(qubits);
                    }
                }
            } else {
                FermionicSwapLayer(swapNetwork[gi], qubits);
            }
        }
    }

    /// # Summary
    /// Create an EvolutionFunction that evolves a single swap or Hamiltonian
    /// layer in a swap network. An EvolutionGenerator uses these to perform
    /// a Trotter step.
    ///
    /// # Input
    /// ## swapNetwork
    /// The network of layers of swaps to perform.
    /// ## localEvolutions
    /// Local evolutions to be performed between swap layers.
    /// ## generatorIndex
    /// An index indicating the swap or Hamiltonian interaction layer to evolve.
    ///
    /// # Output
    /// An EvolutionFunction that evolves the layer.
    function FermionicSwapEvolutionFunction(
        swapNetwork : (Int,Int)[][],
        localEvolutions : JWOptimizedHTerms[][],
        generatorIndex : GeneratorIndex
    ) : EvolutionUnitary {
        return EvolutionUnitary(FermionicSwapEvolutionImpl(swapNetwork, localEvolutions, generatorIndex, _, _));
    }

    /// # Summary
    /// Return an EvolutionSet for a swap network.
    ///
    /// # Input
    /// ## swapNetwork
    /// The fermionic swaps to be performed.
    /// ## localEvolutions
    /// Local evolutions to be performed between swap layers.
    ///
    /// # Output
    /// An EvolutionSet which converts indices to layer evolutions.
    function FermionicSwapEvolutionSet(
        swapNetwork : (Int,Int)[][],
        localEvolutions : JWOptimizedHTerms[][]
    ) : EvolutionSet {
        return EvolutionSet(FermionicSwapEvolutionFunction(swapNetwork, localEvolutions, _));
    }

    /// # Summary
    /// Return a GeneratorSystem for a fermionic swap network
    ///
    /// # Inputs
    /// ## Size
    /// The size of the system. Should be twice the number of swap layers, plus
    /// one.
    ///
    /// # Output
    /// A GeneratorSystem.
    function FermionicSwapGeneratorSystem(
        size : Int
    ) : GeneratorSystem {
        return GeneratorSystem(size, s -> GeneratorIndex(([s], []), []));
    }

    /// # Summary
    /// Internal implementation of timed evolution of a Hamiltonian through
    /// Trotterized swap network.
    ///
    /// # Input
    /// ## stepSize
    /// Duration of a Trotter step.
    /// ## time
    /// Duration of the evolution.
    /// ## generator
    /// An EvolutionGenerator.
    /// ## qubits
    /// The qubits in the system to be acted upon.
    operation FermionicSwapSimulationAlgorithmImpl(
        stepSize : Double,
        time : Double,
        generator : EvolutionGenerator,
        qubits : Qubit[]
    ) : Unit is Adj + Ctl {
        let (evoSet, genSys) = generator!;
        let (numTerms, termDict) = genSys!;
        let timeSteps = Ceiling(time / stepSize);
        for i in 1..timeSteps {
            let thisTime = (i<timeSteps ? stepSize | time - (stepSize * IntAsDouble(timeSteps-1))); 
            for s in i%2==1 ? (1..numTerms) | (numTerms..-1..1) {
                evoSet!(termDict(s))!(thisTime,qubits);
            }
        }
    }

    /// # Summary
    /// Return a SimulationAlgorithm for Trotterized evolution of a Hamiltonian
    /// via swap network.
    ///
    /// # Input
    /// ## stepSize
    /// The duration of a Trotter step.
    ///
    /// # Output
    /// A SimulationAlgorithm.
    function FermionicSwapSimulationAlgorithm(
        stepSize : Double
    ) : SimulationAlgorithm {
        return SimulationAlgorithm(FermionicSwapSimulationAlgorithmImpl(
            stepSize, _,_,_));
    }

    /// # Summary
    /// Create an EvolutionGenerator for a swap network and localized Hamiltonian term evolutions
    ///
    /// # Input
    /// ## swapNetwork
    /// Array of swap layers in the network.
    /// ## localEvolutions
    /// Local evolutions to perform between each swap layer
    ///
    /// # Output
    /// An EvolutionGenerator
    function FermionicSwapEvolutionGenerator(
        swapNetwork : (Int,Int)[][],
        localEvolutions : JWOptimizedHTerms[][]
    ) : EvolutionGenerator {
        return EvolutionGenerator(
            FermionicSwapEvolutionSet(swapNetwork, localEvolutions),
            FermionicSwapGeneratorSystem(Length(swapNetwork) + Length(localEvolutions))
        );
    }
}