// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Qiskit
{
    /*
     * Quick and dirty driver to enable the IbmQx5
     */
    class IbmQx5 : QiskitDriver
    {
        public IbmQx5(string key) : base(key)
        {
        }

        public override int QBitCount => 16;

        public override string Name => "ibmqx5";
    }
}
