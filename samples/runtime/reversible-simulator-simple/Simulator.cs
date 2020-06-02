// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Samples
{
    // The ReversibleSimulator will be implemented based on
    // `QuantumProcessorDispatcher`, which is constructed using a specialization
    // `QuantumProcessorBase`.  The specialization overrides methods to specify
    // actions on intrinsic operations in the Q# code.
    class ReversibleSimulatorProcessor : QuantumProcessorBase {
        // For simplicity, we are using a dictionary to map qubits to their
        // current simulation value.
        private IDictionary<Qubit, bool> simulationValues = new Dictionary<Qubit, bool>();

        // This method is called whenever new qubits are allocated using a
        // `using` statement in Q#.  The newly allocated qubits are passed as
        // an argument to the method.
        public override void OnAllocateQubits(IQArray<Qubit> qubits) {
            // Each allocated qubit is inserted into the dictionary with an
            // initial value of `false`.
            foreach (var qubit in qubits) {
                simulationValues[qubit] = false;
            }
        }

        // Whenever qubits are released, when leaving the scope of a `using`
        // statement in Q#, this method is called with the qubits that are
        // being released.
        public override void OnReleaseQubits(IQArray<Qubit> qubits) {
            // Each released qubit is removed from the dictionary.
            foreach (var qubit in qubits) {
                simulationValues.Remove(qubit);
            }
        }

        // This method is called on a non-controlled `X` operation, applied to
        // the qubit `qubit`.
        public override void X(Qubit qubit) {
            // The simulation value of the qubit is inverted.
            simulationValues[qubit] = !simulationValues[qubit];
        }

        // This helper method returns true, if and only if the simulation value
        // of all qubits in the array `qubits` is true.  It is used in the
        // implementation of a controlled X operation.
        private bool And(IQArray<Qubit> qubits) {
            foreach (var qubit in qubits) {
                if (!simulationValues[qubit]) {
                    return false;
                }
            }
            return true;
        }

        // This method is called on a controlled `X` operation (incl. CNOT and
        // CCNOT), with controls on `controls`, applied to the qubit `qubit.
        public override void ControlledX(IQArray<Qubit> controls, Qubit qubit) {
            // The right-hand side evaluates to true, if and only if the
            // simulation value of all control qubits is `true`.  In that case
            // the simulation value of the target qubit is inverted.
            simulationValues[qubit] ^= And(controls);
        }

        // This method is called when the `Reset` operation is called in the Q#
        // program.  The qubit will still be available, in contrast to a
        // released qubit.
        public override void Reset(Qubit qubit) {
            // The simulation value is reset to the initial value `false`.
            simulationValues[qubit] = false;
        }

        // When calling `M` on some qubit `qubit`, this method is called.  The
        // method returns an instance of type `Result`.
        public override Result M(Qubit qubit) =>
            // The simulation value is converted to a Q# result value: `true`
            // corresponds to `One`, and `false` corresponds to `Zero`.
            simulationValues[qubit].ToResult();
    }

    // The actual simulator is created by extending
    // `QuantumProcessorDispatcher`, which is constructed using the
    // `ReversibleSimulatorProcessor`.
    public class ReversibleSimulator : QuantumProcessorDispatcher {
        public ReversibleSimulator() : base(new ReversibleSimulatorProcessor()) {}
    }
}
