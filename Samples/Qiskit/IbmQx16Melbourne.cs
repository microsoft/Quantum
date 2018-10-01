// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Qiskit
{
    /*
     * Quick and dirty driver to enable the IbmQx16Melbourne
     */
    class IbmQx16Melbourne : QiskitDriver
    {
        public IbmQx16Melbourne(string key) : base(key)
        {
        }

        //Not all 16 qubits are availible
        public override int QBitCount => 14;

        public override string Name => "ibmq_16_melbourne";
    }
}
