// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Samples
{
    internal class QpicProcessor : QuantumProcessorBase
    {
        // This dictionary tracks open `SaveImage` scopes with the filename as
        // its key and a `StringBuilder` object as value.  The `StringBuilder`
        // object is populated with ⟨q|pic⟩ commands for all open scopes.
        public Dictionary<String, StringBuilder> Pictures { get; } = new Dictionary<String, StringBuilder>();

        // This dictionary tracks measured qubits in `if` statements.  The key
        // is the qubit id and the value is a pair consisting of the
        // corresponding `Qubit` object and a flag that controls whether
        // operations are classically controlled on a |0〉 value or a |1〉 value.
        private Dictionary<long, (Qubit, bool)> classicallyControlledQubits = new Dictionary<long, (Qubit, bool)>();

        // This method adds a ⟨q|pic⟩ command to all open `StringBuilder` objects
        // corresponding to all open `SavePicture` scopes.  It also extends
        // commands with classical control directives if necessary.  Qubit
        // objects should be passed as argument, and not as part of the format
        // string.
        public void AddCommand(string format, params object[] args) {
            // get all Qubit objects from args
            var qubitIds = args.OfType<Qubit>();

            foreach (var builder in Pictures.Values) {
                builder.AppendFormat(QpicFormatter.Instance, format, args);
                foreach (var (qubit, invert) in classicallyControlledQubits.Values) {
                    if (!qubitIds.Contains(qubit)) {
                        builder.AppendFormat(QpicFormatter.Instance, " {1}{0}", qubit, invert ? "-" : "");
                    }
                }
                builder.AppendLine();
            }
        }

        #region Quantum operations
        public override void OnAllocateQubits(IQArray<Qubit> qubits) {
            foreach (var qubit in qubits) {
                AddCommand("{0} W", qubit);
            }
        }

        public override void X(Qubit qubit) {
            AddCommand("{0} X", qubit);
        }

        public override void ControlledX(IQArray<Qubit> controls, Qubit qubit) {
            var format = String.Join(" ", Enumerable.Range(0, (int)controls.Length).Select(i => $"{{{i}}}")) + $" +{{{controls.Length}}}";

            AddCommand(format, controls.Append(qubit).ToArray<object>());
        }

        public override void Y(Qubit qubit) {
            AddCommand("{0} Y", qubit);
        }

        public override void ControlledY(IQArray<Qubit> controls, Qubit qubit) {
            var format = "{{{0}}} Y " + String.Join(" ", Enumerable.Range(0, (int)controls.Length).Select(i => $"{{{i + 1}}}"));

            AddCommand(format, controls.Append(qubit).ToArray<object>());
        }

        public override void Z(Qubit qubit) {
            AddCommand("{0} Z", qubit);
        }

        public override void ControlledZ(IQArray<Qubit> controls, Qubit qubit) {
            var format = "{{{0}}} Z " + String.Join(" ", Enumerable.Range(0, (int)controls.Length).Select(i => $"{{{i + 1}}}"));

            AddCommand(format, controls.Prepend(qubit).ToArray<object>());
        }

        public override void H(Qubit qubit) {
            AddCommand("{0} H", qubit);
        }

        public override void S(Qubit qubit) {
            AddCommand("{0} G {{$S$}}", qubit);
        }

        public override void SAdjoint(Qubit qubit) {
            AddCommand("{0} G {{$S^\\dagger$}}", qubit);
        }

        public override void T(Qubit qubit) {
            AddCommand("{0} G {{$T$}}", qubit);
        }

        public override void TAdjoint(Qubit qubit) {
            AddCommand("{0} G {{$T^\\dagger$}}", qubit);
        }

        public override void Reset(Qubit qubit) {
            AddCommand("{0} OUT {{0}}", qubit);
        }
        #endregion

        #region Classical control
        // This is a custom Result class which can hold the qubit that is being
        // measured.  In this simulator we are not interested in the simulation
        // value, but need to keep track of qubits that were measured to
        // support classical control.
        class DelayedResult : Result {
            public Qubit Qubit { get; set; }

            // Since we are not interested in the outcome of a measurement, we
            // simply return One.  This method needs to be implemented to avoid
            // an exception being thrown, but the value will not be used by
            // the simulator.
            public override ResultValue GetValue() {
                return ResultValue.One;
            }
        }

        // A measurement is used to keep track of the measured qubit, and adds a
        // ⟨q|pic⟩ measurement command.
        public override Result M(Qubit qubit) {
            AddCommand("{0} M", qubit);
            return new DelayedResult { Qubit = qubit };
        }

        // When starting a conditional statement, the measured qubit is obtained
        // from the measurementResult argument.  The inversion flag is
        // initialized with respect to the result value.  If it's `Zero`,
        // operations in the `then` clause are negatively controlled, and
        // operations in the `else` clause are positively controlled.  If it's
        // `One`, it's the other way around.  Both variables are inserted into
        // the dictionary for classically controlled qubits.  The qubit's id is
        // used as identifier to link successive methods to the same conditinal
        // statement.
        public override long StartConditionalStatement(Result measurementResult, Result resultValue) {
            var qubit = ((DelayedResult)measurementResult).Qubit;
            var invert = resultValue == Result.Zero;
            classicallyControlledQubits.Add(qubit.Id, (qubit, invert));
            return qubit.Id;
        }

        // No action needs to be taken in the `RunThenClause` method.  It
        // returns true to ensure that the corresponding operations in the
        // `then` clause are executed.  The `statement` parameter corresponds to
        // the return value of `StartConditionalStatement` to link conditional
        // statements that involve the same qubit.
        public override bool RunThenClause(long statement) => true;

        // In the `RunElseClause` method the invert flag of the corresponding
        // dictionary entry is toggled.  The method also returns true to ensure
        // that the corresponding operations in the `else` clause are executed.
        // The `statement` parameter corresponds to the return value of
        // `StartConditionalStatement` to link conditional statements that
        // involve the same qubit.
        public override bool RunElseClause(long statement) {
            var (qubit, invert) = classicallyControlledQubits[statement];
            classicallyControlledQubits[statement] = (qubit, !invert);
            return true;
        }

        // When finishing a conditional statement, the corresponding entry is
        // removed from the dictionary, and a ⟨q|pic⟩ command for the visual
        // termination of the measured qubit is added.  The `statement`
        // parameter corresponds to the return value of
        // `StartConditionalStatement` to link conditional statements that
        // involve the same qubit.
        public override void EndConditionalStatement(long statement) {
            var (qubit, _) = classicallyControlledQubits[statement];
            AddCommand("{0} OUT {{}}", qubit);
            classicallyControlledQubits.Remove(statement);
        }
        #endregion
    }
}
