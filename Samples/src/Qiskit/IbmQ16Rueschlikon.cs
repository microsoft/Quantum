// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Qiskit
{
    /*
     * Quick and dirty driver to enable the Rueschlikon (former IbmQx5)
     */
    class IbmQ16Rueschlikon : QiskitDriver
    {
        public IbmQ16Rueschlikon(string key) : base(key)
        {
        }

        public override int QBitCount => 16;

        public override string Name => "ibmq_16_rueschlikon";
    }
}
