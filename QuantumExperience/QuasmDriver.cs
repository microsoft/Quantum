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
        protected abstract List<Result> RunQuasm(StringBuilder quasm);
        public abstract int QBitCount { get; }
       
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
                        QuasmLog.AppendLine("h q[" + (uint)q1.Id + "];");
                        return QVoid.Instance;
                    };
                }
            }
        }

        public override void StartOperation(string operationName, OperationFunctor functor, object inputValue)
        {
            QuasmLog = new StringBuilder();

            QuasmLog.AppendLine("include \"qelib1.inc\";");
            QuasmLog.AppendLine($"qreg q[{QBitCount}];");
            QuasmLog.AppendLine($"creg c[{QBitCount}];");
            base.StartOperation(operationName, functor, inputValue);
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

        public class QSimCCNOT : CCNOT
        {
            public QSimCCNOT(IOperationFactory m) : base(m)
            {
            }

            public override Func<(Qubit, Qubit, Qubit), QVoid> Body
            {
                get
                {
                    throw new NotImplementedException();
                }
            }
        }

        public class QSimCNOT : CNOT
        {
            public QSimCNOT(IOperationFactory m) : base(m)
            {
            }

            public override Func<(Qubit, Qubit), QVoid> Body
            {
                get
                {
                    throw new NotImplementedException();
                }
            }
        }

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
                        QuasmLog.AppendLine("measure q[" + (uint)q.Id + "] -> c[" + (uint)q.Id + "];");
                        
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

        public class QSimMeasure : Measure
        {
            public QSimMeasure(IOperationFactory m) : base(m)
            {
            }

            public override Func<(QArray<Pauli>, QArray<Qubit>), Result> Body => throw new NotImplementedException();
        }

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
                        Console.WriteLine("X q" + (uint)q1.Id);
                        return QVoid.Instance;
                    };
                }
            }
        }

        public static StringBuilder QuasmLog
        {
            get; set;
        }
    }
}
