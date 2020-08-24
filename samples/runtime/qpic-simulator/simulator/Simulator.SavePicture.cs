// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System;
using System.Text;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Samples
{
    public partial class QpicSimulator : QuantumProcessorDispatcher {
        // Implementation of the `SavePicture` operation for the QpicSimulator
        public class SavePictureImpl : SavePicture {
            private QpicProcessor processor;

            public SavePictureImpl(QpicSimulator m) : base(m) {
                processor = (QpicProcessor)m.QuantumProcessor;
            }

            // The body operation adds a new empty scope to the processor
            // indexed by the filename.
            public override Func<String, QVoid> Body => filename => {
                processor.Pictures.Add(filename, new StringBuilder());
                return QVoid.Instance;
            };

            // The adjoint operation saves the picture and removes the scope
            // from the processor.
            public override Func<String, QVoid> AdjointBody => filename => {
                System.IO.File.WriteAllText(filename, processor.Pictures[filename].ToString());
                processor.Pictures.Remove(filename);
                return QVoid.Instance;
            };
        }
    }
}
