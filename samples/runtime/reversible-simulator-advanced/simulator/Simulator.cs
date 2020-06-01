// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections;
using System.Linq;
using Microsoft.Quantum.Canon;
using Microsoft.Quantum.Intrinsic;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;

namespace Microsoft.Quantum.Samples
{
    // The ReversibleSimulator will be implemented based on
    // `QuantumProcessorDispatcher`, which is constructed using a specialization
    // `QuantumProcessorBase`.  The specialization overrides methods to specify
    // actions on intrinsic operations in the Q# code.
    class ReversibleSimulatorProcessor : QuantumProcessorBase {
        // This property controls whether to throw an exception when a qubit is
        // released that is not in the zero state.
        public bool ThrowOnReleasingQubitsNotInZeroState { get; set; } = true;

        // The simulation values are stored in the bits of a BitArray, which
        // can use integers to store several bits at once.  We initialize the
        // bit array to contain up to 64 bits and will dynamically grow it,
        // whenever this capacity is exceeded.
        private BitArray simulationValues = new BitArray(64);

        // We implement three helper functions to manipulate the bits in the
        // bit array given a qubit as input.
        // GetValue returns the simulation value at the corresponding index.
        private bool GetValue(Qubit qubit) =>
            simulationValues[qubit.Id];

        // SetValue sets the simulation value at the corresponding index.
        private void SetValue(Qubit qubit, bool value) {
            simulationValues[qubit.Id] = value;
        }

        // InvertValue inverts the simulation value at the corresponding index.
        private void InvertValue(Qubit qubit) {
            simulationValues[qubit.Id] = !simulationValues[qubit.Id];
        }

        // When allocating a qubit whose index equals or exceeds the current
        // number of simulation values stored in the bit array, the bit array
        // is resized to twice its current size.
        public override void OnAllocateQubits(IQArray<Qubit> qubits) {
            var maxId = qubits.Max(q => q.Id);
            while (maxId >= simulationValues.Length) {
                simulationValues.Length *= 2;
            }
        }

        // When releasing qubits that are not in the zero state, their value
        // is reset to false.  If the ThrowOnReleasingQubitsNotInZeroState property
        // is assigned true, an exception is thrown.
        public override void OnReleaseQubits(IQArray<Qubit> qubits) {
            foreach (var qubit in qubits) {
                if (GetValue(qubit)) {
                    if (ThrowOnReleasingQubitsNotInZeroState) {
                        throw new ReleasedQubitsAreNotInZeroState();
                    }
                    SetValue(qubit, false);
                }
            }
        }

        // An X operation inverts the bit in the `simulationValues` variable at
        // the position of the qubit's index.
        public override void X(Qubit qubit) {
            InvertValue(qubit);
        }

        // If the simulation values of all control qubits are assigned true,
        // the simulation value of the target qubit is inverted.
        public override void ControlledX(IQArray<Qubit> controls, Qubit qubit) {
            if (controls.All(control => GetValue(control))) {
                InvertValue(qubit);
            }
        }

        // If the simulation value of qubit is true, when it's being reset, we
        // restore it to false.
        public override void Reset(Qubit qubit) {
            SetValue(qubit, false);
        }

        // Measuring the qubit corresponds to translating the current simulation
        // value into a Result value.
        public override Result M(Qubit qubit) =>
            GetValue(qubit).ToResult();

        // Overriding the Assert methods enables the use of statements such as
        // `AssertQubit(Zero, q)` inside a Q# program.
        public override void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result expected, string msg) {
            Qubit? filter(Pauli p, Qubit q) =>
                p switch {
                    Pauli.PauliI => null,
                    Pauli.PauliZ => q,
                    _ => throw new InvalidOperationException("Assert on bases other than PauliZ not supported")
                };

            // All qubits are considered whose corresponding measurement basis
            // is PauliZ.  Measurement in PauliI basis are ignored, and other
            // bases will raise an exception.
            var qubitsToMeasure = bases.Zip(qubits, filter).WhereNotNull();

            // A multi-qubit measurement in the PauliZ basis corresponds to
            // computing the parity of all involved qubits' measurement values.
            // (see also https://docs.microsoft.com/quantum/concepts/pauli-measurements#multiple-qubit-measurements)
            // We use Aggregate to successively XOR a qubit's simulation value
            // to an accumulator value `accu` that is initialized to `false`.
            var actual = qubitsToMeasure.Aggregate(false, (accu, qubit) => accu ^ GetValue(qubit));
            if (actual.ToResult() != expected) {
                // If the expected value does not correspond to the actual measurement
                // value, we throw a Q# specific Exception together with the user
                // defined message `msg`.
                throw new ExecutionFailException(msg);
            }
        }
    }

    public class ReversibleSimulator : QuantumProcessorDispatcher {
        // Whether an exception is thrown when releasing qubits that are in a
        // non-zero state is configured as an argument to the constructor of
        // ReversibleSimulator, defaulted to `true`.
        public ReversibleSimulator(bool throwOnReleasingQubitsNotInZeroState = true)
            : base(new ReversibleSimulatorProcessor { ThrowOnReleasingQubitsNotInZeroState = throwOnReleasingQubitsNotInZeroState }) {

            // We register the ApplyAnd and the ApplyLowDepthAnd operation as
            // CCNOT operations.  These are both standard library operations
            // in the Microsoft.Quantum.Canon namespace. By doing this, Q#
            // programs that contain these operations can be simulated using
            // the reversible simulator, even though they are using non-classical
            // operations in their implementation.
            Register(typeof(ApplyAnd), typeof(CCNOT), typeof(IUnitary<(Qubit, Qubit, Qubit)>));
            Register(typeof(ApplyLowDepthAnd), typeof(CCNOT), typeof(IUnitary<(Qubit, Qubit, Qubit)>));
        }
    }
}
