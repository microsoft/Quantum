// Copyright Battelle Memorial Institute 2022. All rights reserved.

// QSharp unit tests for Fermionic Swap QSharp code.
// These are tests are driven from the C# unit tests;
// See notes in FermionicSwap.qs for rationale.
namespace FermionicSwap.Tests {
    open Microsoft.Quantum.Simulation;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Chemistry;
    open Microsoft.Quantum.Chemistry.JordanWigner;
    open Microsoft.Quantum.Arrays;
    open FermionicSwap;

    // We open the diagnostics namespace under an alias to help avoid
    // conflicting with deprecation stubs in Microsoft.Quantum.Canon.
    open Microsoft.Quantum.Diagnostics as Diag;

    // This test as currently written will only work for Hamiltonians with a
    // single summand due to Trotter summand reordering issues.
    operation SwapNetworkOneSummandTestOp(swapNetwork : (Int,Int)[][],
                                qsharpNetworkData : JWOptimizedHTerms[][],
                                qsharpHamiltonian : JWOptimizedHTerms,
                                numQubits : Int
                                ) : Unit {
        let time = 1.0;
        Diag.AssertOperationsEqualReferenced(numQubits,
            _FixedOrderFermionicSwapTrotterStep(swapNetwork, qsharpNetworkData, time, _),
            _JordanWignerApplyTrotterStep(qsharpHamiltonian, time, _ )
        );
    }

    // Perform trotter evolution with straight Jordan-Wigner evolution, and
    // using Fermionic swap network. These are only the same in the
    // small stepSize limit.
    operation SwapNetworkEvolutionTestOp(
                                swapNetwork : (Int,Int)[][],
                                qsharpNetworkData : JWOptimizedHTerms[][],
                                qsharpHamiltonian : JWOptimizedHTerms,
                                numQubits : Int,
                                stepSize : Double,
                                time : Double
                                ) : Unit {
        let generatorSystem = JordanWignerGeneratorSystem(qsharpHamiltonian);
        let jwGenerator = EvolutionGenerator(JordanWignerFermionEvolutionSet(), generatorSystem);
        let fsGenerator = FermionicSwapEvolutionGenerator(swapNetwork, qsharpNetworkData);
        Diag.AssertOperationsEqualReferenced(numQubits,
            FermionicSwapEvolveUnderGenerator(fsGenerator, stepSize, time, _),
            _EvolveUnderGenerator(jwGenerator, stepSize, time,_ )
        );
    }

    // Copied from a QDK example
    operation _EvolveUnderGenerator(generator : EvolutionGenerator, trotterStepSize : Double, time : Double, register : Qubit[])
    : Unit is Adj + Ctl {
        let trotterOrder = 1;
        let evolveFor = (TrotterSimulationAlgorithm(trotterStepSize, trotterOrder))!;
        evolveFor(time, generator, register);
    }


    operation _FixedOrderFermionicSwapTrotterStep(swapNetwork : (Int,Int)[][],
                                qsharpNetworkData : JWOptimizedHTerms[][],
                                time : Double, qubits : Qubit[]) : Unit {
        FermionicSwapTrotterStep(swapNetwork, qsharpNetworkData, time, qubits);
        let empty = new JWOptimizedHTerms[][Length(swapNetwork)+1];
        FermionicSwapTrotterStep(Reversed(swapNetwork), empty, 0.0, qubits);
    }

    operation _JordanWignerApplyTrotterStep (data : JWOptimizedHTerms, trotterStepSize : Double, qubits :
Qubit[])
    : Unit is Adj + Ctl {
        let generatorSystem = JordanWignerGeneratorSystem(data);
        let evolutionGenerator = EvolutionGenerator(JordanWignerFermionEvolutionSet(), generatorSystem);
        let trotterOrder = 1;
        TrotterStep(evolutionGenerator, trotterOrder, trotterStepSize)(qubits);
    }
}