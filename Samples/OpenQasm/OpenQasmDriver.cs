// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using Microsoft.Quantum.Primitive;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Common;

namespace Microsoft.Quantum.Samples.OpenQasm
{
    /// <summary>
    /// Quick and dirty Simulatorbase to write OpenQASM 2.0
    /// Just enough to show that it would work
    /// Please don't put this in production until its fully engineered.
    /// This code could eat your cat. So imagine what Schrodinger has to say about that one.
    /// </summary>
    public abstract class OpenQasmDriver : SimulatorBase
    {
        public OpenQasmDriver(IQubitManager qubitManager = null) : base(qubitManager)
        {
            QasmLog.AppendLine("include \"qelib1.inc\";");
            QasmLog.AppendLine($"qreg q[{QBitCount}];");
            QasmLog.AppendLine($"creg c[{QBitCount}];");
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
                    return delegate (Qubit q)
                    {
                        if (q == null)
                        {
                            return QVoid.Instance;
                        }
                        var driver = (Factory as OpenQasmDriver);
                        driver.QasmLog.AppendLine($"h q[{q.Id}];");
                        return QVoid.Instance;
                    };
                }
            }
        }

        /// <summary>
        /// Ignored because this machine doesn't have it. And we recycle qubits anyway
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
                        var driver = (Factory as OpenQasmDriver);
                        driver.QasmLog.AppendLine($"measure q[{(uint)q.Id}] -> c[{(uint)q.Id}];");
                        var result = driver.RunOpenQasm(driver.QasmLog,1).ToArray();
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
                    return delegate (Qubit q)
                    {
                        if (q == null)
                        {
                            return QVoid.Instance;
                        }
                        var driver = (Factory as OpenQasmDriver);
                        driver.QasmLog.AppendLine($"x q[{q.Id}];");
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
                    return delegate (Qubit q)
                    {
                        if (q == null)
                        {
                            return QVoid.Instance;
                        }
                        var driver = (Factory as OpenQasmDriver);
                        driver.QasmLog.AppendLine($"y q[{q.Id}];");
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
                    return delegate (Qubit q)
                    {
                        if (q == null)
                        {
                            return QVoid.Instance;
                        }
                        var driver = (Factory as OpenQasmDriver);
                        driver.QasmLog.AppendLine($"z q[{q.Id}];");
                        return QVoid.Instance;
                    };
                }
            }
        }

        /// <summary>
        /// Ignoring Asserts, because OpenQasm doesn't have them and don't add behavior unless hit.
        /// </summary>
        public class QSimAssert : Assert
        {
            public QSimAssert(IOperationFactory m) : base(m)
            {
            }

            public override Func<(QArray<Pauli>, QArray<Qubit>, Result, string), QVoid> Body
            {
                get {
                    return delegate ((QArray<Pauli>, QArray<Qubit>, Result, string) assert)
                    {
                        return QVoid.Instance;
                    };
                }
            }
        }
        /// <summary>
        /// Ignoring AssertProbes, because OpenQasm doesn't have them and don't add behavior unless hit.
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
                    return delegate ((QArray<Pauli>, QArray<Qubit>, Result, double, string, double) assert)
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
                    return delegate ((Qubit, Qubit) cnot)
                    {
                        if (cnot.Item1 == null || cnot.Item2 == null)
                        {
                            return QVoid.Instance;
                        }
                        var driver = (Factory as OpenQasmDriver);
                        driver.QasmLog.AppendLine($"cx q[{cnot.Item1.Id}],q[{cnot.Item2.Id}];");
                        return QVoid.Instance;
                    };
                }
            }
        }

        /// <summary>
        /// Process R Gate
        /// </summary>
        public class QSimR : R
        {
            public QSimR(IOperationFactory m) : base(m)
            {
            }

            public override Func<(Pauli, double, Qubit), QVoid> Body
            {
                get
                {
                    return delegate ((Pauli, double, Qubit) rGate)
                    {
                        if (rGate.Item3 == null)
                        {
                            return QVoid.Instance;
                        }
                        var driver = (Factory as OpenQasmDriver);
                        switch (rGate.Item1)
                        {
                            case Pauli.PauliI:
                                driver.QasmLog.AppendLine($"U({rGate.Item2},{rGate.Item2},{rGate.Item2}) q[{rGate.Item3.Id}];");
                                break;
                            case Pauli.PauliX:
                                driver.QasmLog.AppendLine($"rx({rGate.Item2}) q[{rGate.Item3.Id}];");
                                break;
                            case Pauli.PauliY:
                                driver.QasmLog.AppendLine($"ry({rGate.Item2}) q[{rGate.Item3.Id}];");
                                break;
                            case Pauli.PauliZ:
                                driver.QasmLog.AppendLine($"rz({rGate.Item2}) q[{rGate.Item3.Id}];");
                                break;
                        }
                        return QVoid.Instance;
                    };
                }
            }
        }

        //Log of the current to be executing Qasm
        public readonly StringBuilder QasmLog = new StringBuilder();

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
