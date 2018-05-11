// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Quantum.Primitive;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Quasm
{
    /// <summary>
    /// Quick and dirty Simulatorbase
    /// Just enough to show that it would work
    /// Please don't put this in production until its fully engineerd.
    /// This code could eat your cat. So imagine what schrodinger has to say about that one.
    /// </summary>
    public abstract class QuasmDriver : SimulatorBase
    {
        public QuasmDriver(): base()
        {
            AppendHeader();
        }

        /// <summary>
        /// Generate the openqasm header
        /// </summary>
        private void AppendHeader()
        {
            QuasmLog.AppendLine("include \"qelib1.inc\";");
            QuasmLog.AppendLine($"qreg q[{QBitCount}];");
            QuasmLog.AppendLine($"creg c[{QBitCount}];");
        }

        protected abstract List<Result> RunQuasm(StringBuilder quasm);
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

                        Console.WriteLine("");
                        Console.WriteLine("QUASM file");
                        Console.Write(QuasmLog.ToString());
                        Console.WriteLine("");
                        var result = (Factory as QuasmDriver).RunQuasm(QuasmLog);
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
