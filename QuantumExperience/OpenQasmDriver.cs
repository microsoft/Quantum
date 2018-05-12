// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using Microsoft.Quantum.Primitive;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.OpenQasm
{
    /// <summary>
    /// Quick and dirty Simulatorbase to write OpenQASM 2.0
    /// Just enough to show that it would work
    /// Please don't put this in production until its fully engineerd.
    /// This code could eat your cat. So imagine what schrodinger has to say about that one.
    /// </summary>
    public abstract class OpenQasmDriver : SimulatorBase
    {
        private int operationDepth;
        public override void StartOperation(string operationName, OperationFunctor functor, object inputValue)
        {
            if (operationDepth == 0)
            {
                QuasmLog.AppendLine("include \"qelib1.inc\";");
                QuasmLog.AppendLine($"qreg q[{QBitCount}];");
                QuasmLog.AppendLine($"creg c[{QBitCount}];");
            }
            operationDepth++;
            base.StartOperation(operationName, functor, inputValue);
        }

        public override void EndOperation(string operationName, OperationFunctor functor, object resultValue)
        {
            base.EndOperation(operationName, functor, resultValue);
            operationDepth--;
            if (operationDepth == 0)
            {
                QuasmLog.Clear();
            }
        }

        protected abstract IEnumerable<Result> RunOpenQasm(StringBuilder qasm, int runs);
        public abstract int QBitCount { get; }

        /// <summary>
        /// Processes Hadamard gate
        /// </summary>
        public class QSimH : H
        {
            public QSimH(IOperationFactory m) : base(m)
            {
            }

            public override Func<Qubit, QVoid> Body
            {
                get
                {
                    return delegate (Qubit q1)
                    {
                        if (q1 == null)
                        {
                            return QVoid.Instance;
                        }
                        QuasmLog.AppendLine($"h q[{q1.Id}];");
                        return QVoid.Instance;
                    };
                }
            }
        }

        /// <summary>
        /// Ingnored becuase this machine doesn't have it. And we recycle qubits anyway
        /// </summary>
        public class QSimReset : Reset
        {
            public QSimReset(IOperationFactory m) : base(m)
            {
            }

            public override Func<Qubit, QVoid> Body
            {
                get
                {
                    return delegate (Qubit q)
                    {
                        return QVoid.Instance;
                    };
                }
            }
        }

        /// <summary>
        /// Processes Measurement gate
        /// Every measurement will currently trigger a schedule of a job
        /// </summary>
        public class QSimM : M
        {
            public QSimM(IOperationFactory m) : base(m)
            {
            }

            public override Func<Qubit, Result> Body
            {
                get
                {
                    return delegate (Qubit q)
                    {
                        if (q == null)
                        {
                            return Result.Zero;
                        }
                        QuasmLog.AppendLine($"measure q[{(uint)q.Id}] -> c[{(uint)q.Id}];");
                        var result = (Factory as OpenQasmDriver).RunOpenQasm(QuasmLog,1).ToArray();
                        return result[q.Id];
                    };
                }
            }
        }

        /// <summary>
        /// Processes Pauli-X gate
        /// </summary>
        public class QSimX : X
        {
            public QSimX(IOperationFactory m) : base(m)
            {
            }

            public override Func<Qubit, QVoid> Body
            {
                get
                {
                    return delegate (Qubit q1)
                    {
                        if (q1 == null)
                        {
                            return QVoid.Instance;
                        }
                        QuasmLog.AppendLine($"x q[{q1.Id}];");
                        return QVoid.Instance;
                    };
                }
            }
        }

        /// <summary>
        /// Processes Pauli-Y gate
        /// </summary>
        public class QSimY : Y
        {
            public QSimY(IOperationFactory m) : base(m)
            {
            }

            public override Func<Qubit, QVoid> Body
            {
                get
                {
                    return delegate (Qubit q1)
                    {
                        if (q1 == null)
                        {
                            return QVoid.Instance;
                        }
                        QuasmLog.AppendLine($"y q[{q1.Id}];");
                        return QVoid.Instance;
                    };
                }
            }
        }

        /// <summary>
        /// Processes Pauli-Y gate
        /// </summary>
        public class QSimZ : Z
        {
            public QSimZ(IOperationFactory m) : base(m)
            {
            }

            public override Func<Qubit, QVoid> Body
            {
                get
                {
                    return delegate (Qubit q1)
                    {
                        if (q1 == null)
                        {
                            return QVoid.Instance;
                        }
                        QuasmLog.AppendLine($"z q[{q1.Id}];");
                        return QVoid.Instance;
                    };
                }
            }
        }

        /// <summary>
        /// Ignoring Asserts, because OpenQuasm doesn't have them and don't add behavior unless hit.
        /// </summary>
        public class QSimAssert : Assert
        {
            public QSimAssert(IOperationFactory m) : base(m)
            {
            }

            public override Func<(QArray<Pauli>, QArray<Qubit>, Result, string), QVoid> Body
            {
                get {
                    return delegate ((QArray<Pauli>, QArray<Qubit>, Result, string) q1)
                    {
                        return QVoid.Instance;
                    };
                }
            }
        }
        /// <summary>
        /// Ignoring AssertProbes, because OpenQuasm doesn't have them and don't add behavior unless hit.
        /// </summary>
        public class QSimAssertProb : AssertProb
        {
            public QSimAssertProb(IOperationFactory m) : base(m)
            {
            }

            public override Func<(QArray<Pauli>, QArray<Qubit>, Result, double, string, double), QVoid> Body
            {
                get
                {
                    return delegate ((QArray<Pauli>, QArray<Qubit>, Result, double, string, double) q1)
                    {
                        return QVoid.Instance;
                    };
                }
            }
        }

        /// <summary>
        /// Processes CNOT gate
        /// </summary>
        public class QSimCNOT : CNOT
        {
            public QSimCNOT(IOperationFactory m) : base(m)
            {
            }

            public override Func<(Qubit,Qubit), QVoid> Body
            {
                get
                {
                    return delegate ((Qubit, Qubit) q1)
                    {
                        if (q1.Item1 == null || q1.Item2 == null)
                        {
                            return QVoid.Instance;
                        }
                        QuasmLog.AppendLine($"cx q[{q1.Item1.Id}],q[{q1.Item2.Id}];");
                        return QVoid.Instance;
                    };
                }
            }
        }

        public static readonly StringBuilder QuasmLog = new StringBuilder();

        /// <summary>
        /// Implemented as stub, to work around current reflection bug of simulator base
        /// </summary>
        public class QSimMeasure : Measure
        {
            public QSimMeasure(IOperationFactory m) : base(m)
            {
            }

            public override Func<(QArray<Pauli>, QArray<Qubit>), Result> Body => throw new NotImplementedException();
        }
    }
}
