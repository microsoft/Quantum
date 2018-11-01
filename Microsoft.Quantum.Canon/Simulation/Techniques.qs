// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;

    /// # Summary
    /// This interpolates between two generators with a uniform schedule,
    /// returning an operation that applies simulated evolution under
    /// the resulting time-dependent generator to a qubit register.
    ///
    /// # Input
    /// ## interpolationTime
    /// Time to perform the interpolation over.
    /// ## evolutionGeneratorStart
    /// Initial generator to simulate evolution under.
    /// ## evolutionGeneratorEnd
    /// Final generator to simulate evolution under.
    /// ## timeDependentSimulationAlgorithm
    /// A time-dependent simulation algorithm that will be used
    /// to simulate evolution during the uniform interpolation schedule.
    ///
    /// # Remarks
    /// If the interpolation time is chosen to meet the adiabatic conditions,
    /// then this function returns an operation which performs adiabatic
    /// state preparation for the final dynamical generator.
    function InterpolatedEvolution( interpolationTime: Double,
                                    evolutionGeneratorStart: EvolutionGenerator,
                                    evolutionGeneratorEnd: EvolutionGenerator,
                                    timeDependentSimulationAlgorithm: TimeDependentSimulationAlgorithm)
                                    : (Qubit[] => () : Adjoint, Controlled) {

        //   evolutionSetStart and evolutionSetEnd must be identical
        let (evolutionSetStart, generatorSystemStart) = evolutionGeneratorStart;
        let (evolutionSetEnd, generatorSystemEnd) = evolutionGeneratorEnd;
        let generatorSystemTimeDependent = InterpolateGeneratorSystems(generatorSystemStart, generatorSystemEnd);
        let evolutionSchedule = EvolutionSchedule(evolutionSetStart, generatorSystemTimeDependent);
        return timeDependentSimulationAlgorithm(interpolationTime, evolutionSchedule, _);
    }


    /// # Summary
    /// Convenience function that performs state preparation by applying a 
    /// `statePrepUnitary` on the input state, followed by adiabatic state 
    /// preparation using a `adiabaticUnitary`, and finally phase estimation 
    /// with respect to `qpeUnitary`on the resulting state using a 
    /// `phaseEstAlgorithm`.
    ///
    /// # Input
    /// ## statePrepUnitary
    /// An oracle representing state preparation for the initial dynamical
    /// generator.
    /// ## adiabaticUnitary
    /// An oracle representing the adiabatic evolution algorithm to be used
    /// to implement the sweeps to the final state of the algorithm.
    /// ## qpeUnitary
    /// An oracle representing a unitary operator $U$ representing evolution
    /// for time $\delta t$ under a dynamical generator with ground state
    /// $\ket{\phi}$ and ground state energy $E = \phi\\,\delta t$.
    /// ## phaseEstAlgorithm
    /// An operation that performs phase estimation on a given unitary operation.
    /// See [iterative phase estimation](/quantum/libraries/characterization#iterative-phase-estimation)
    /// for more details.
    /// ## qubits
    /// A register of qubits to be used to perform the simulation.
    ///
    /// # Output
    /// An estimate $\hat{\phi}$ of the ground state energy $\phi$
    /// of the generator represented by $U$.
    operation AdiabaticStateEnergyUnitary(  statePrepUnitary: (Qubit[] => ()),
                                            adiabaticUnitary: (Qubit[] => ()),
                                            qpeUnitary: (Qubit[] => () :  Adjoint, Controlled),
                                            phaseEstAlgorithm : ((DiscreteOracle, Qubit[]) => Double),
                                            qubits: Qubit[]) : Double {
        body {
            statePrepUnitary(qubits);
            adiabaticUnitary(qubits);
            let phaseEst = phaseEstAlgorithm(OracleToDiscrete(qpeUnitary), qubits);
            return phaseEst;
        }
    }

    /// # Summary
    /// Convenience function that performs state preparation by applying a 
    /// `statePrepUnitary` on an automatically allocated input state 
    /// $\ket{0...0}$, followed by adiabatic state preparation using a 
    /// `adiabaticUnitary`, and finally phase estimation with respect to 
    /// `qpeUnitary`on the resulting state using a `phaseEstAlgorithm`.
    ///
    /// # Input
    /// ## nQubits
    /// Number of qubits used for the simulation.
    /// ## statePrepUnitary
    /// An oracle representing state preparation for the initial dynamical
    /// generator.
    /// ## adiabaticUnitary
    /// An oracle representing the adiabatic evolution algorithm to be used
    /// to implement the sweeps to the final state of the algorithm.
    /// ## qpeUnitary
    /// An oracle representing a unitary operator $U$ representing evolution
    /// for time $\delta t$ under a dynamical generator with ground state
    /// $\ket{\phi}$ and ground state energy $E = \phi\\,\delta t$.
    /// ## phaseEstAlgorithm
    /// An operation that performs phase estimation on a given unitary operation.
    /// See [iterative phase estimation](/quantum/libraries/characterization#iterative-phase-estimation)
    /// for more details.
    ///
    /// # Output
    /// An estimate $\hat{\phi}$ of the ground state energy $\phi$
    /// of the generator represented by $U$.
    operation AdiabaticStateEnergyEstimate( nQubits : Int, 
                                            statePrepUnitary: (Qubit[] => ()),
                                            adiabaticUnitary: (Qubit[] => ()),
                                            qpeUnitary: (Qubit[] => () :  Adjoint, Controlled),
                                            phaseEstAlgorithm : ((DiscreteOracle, Qubit[]) => Double)) : Double {
        body {
            mutable phaseEst = ToDouble(0);
            using (qubits = Qubit[nQubits]) {
                set phaseEst = AdiabaticStateEnergyUnitary( statePrepUnitary, adiabaticUnitary, qpeUnitary, phaseEstAlgorithm, qubits);
                ResetAll(qubits);
            }
            return phaseEst;

        }
    }

    /// # Summary
    /// Convenience function that performs state preparation by applying a 
    /// `statePrepUnitary` on an automatically allocated input state 
    /// phase estimation with respect to `qpeUnitary`on the resulting state 
    /// using a `phaseEstAlgorithm`.
    ///
    /// # Input
    /// ## nQubits
    /// Number of qubits used to perform simulation.
    /// ## statePrepUnitary
    /// An oracle representing state preparation for the initial dynamical
    /// generator.
    /// ## qpeUnitary
    /// An oracle representing a unitary operator $U$ representing evolution
    /// for time $\delta t$ under a dynamical generator with ground state
    /// $\ket{\phi}$ and ground state energy $E = \phi\\,\delta t$.
    /// ## phaseEstAlgorithm
    /// An operation that performs phase estimation on a given unitary operation.
    /// See [iterative phase estimation](/quantum/libraries/characterization#iterative-phase-estimation)
    /// for more details.
    ///
    /// # Output
    /// An estimate $\hat{\phi}$ of the ground state energy $\phi$
    /// of the ground state energy of the generator represented by $U$.
    operation EstimateEnergy(nQubits : Int,
                             statePrepUnitary: (Qubit[] => () ),
                             qpeUnitary: (Qubit[] => () :  Adjoint, Controlled),
                             phaseEstAlgorithm : ((DiscreteOracle, Qubit[]) => Double) ) : Double {
         body {
            let phaseEst = AdiabaticStateEnergyEstimate( nQubits, statePrepUnitary, NoOp, qpeUnitary, phaseEstAlgorithm);
            return phaseEst;
        }
    }


}
