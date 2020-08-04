// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
//using System;
//using System.Linq;
//using Microsoft.Quantum.Simulation.QuantumProcessor;
//using Microsoft.Quantum.Simulation.Core;
//
//namespace Microsoft.Quantum.Samples
//{
//    public partial class QpicSimulator : QuantumProcessorDispatcher {
//        public class ControlledOnBitStringImplImpl<T> : Microsoft.Quantum.Canon.ControlledOnBitStringImpl<T> {
//            private QpicProcessor processor;
//
//            public ControlledOnBitStringImplImpl(QpicSimulator m) : base(m) {
//                processor = (QpicProcessor)m.QuantumProcessor;
//            }
//
//            private void AddCustomQpicCommand(IQArray<bool> bits, IQArray<Qubit> controls, T target) {
//                var controlsStr = String.Join(" ", controls.Zip(bits, (qubit, polarity) => String.Format(QpicFormatter.Instance, "{0}{1}", polarity ? "" : "-", qubit)));
//                processor.AddCommand("{0} +{1}", controlsStr, target);
//            }
//
//            public override Func<(IQArray<bool>, IUnitary, IQArray<Qubit>, T), QVoid> Body => (args) => {
//                var (bits, oracle, controls, target) = args;
//
//                if (oracle.FullName == "Microsoft.Quantum.Intrinsic.X") {
//                    AddCustomQpicCommand(bits, controls, target);
//                    return QVoid.Instance;
//                } else {
//                    return base.Body(args);
//                }
//            };
//
//            public override Func<(IQArray<bool>, IUnitary, IQArray<Qubit>, T), QVoid> AdjointBody => (args) => {
//                var (bits, oracle, controls, target) = args;
//
//                if (oracle.FullName == "Microsoft.Quantum.Intrinsic.X") {
//                    AddCustomQpicCommand(bits, controls, target);
//                    return QVoid.Instance;
//                } else {
//                    return base.AdjointBody(args);
//                }
//            };
//        }
//    }
//}
//