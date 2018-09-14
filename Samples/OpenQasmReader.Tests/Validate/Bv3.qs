// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation Bv3():(Result[])
    {
        body
        {
            mutable c = new Result[4];
            using(q = Qubit[5]){
                X(q[2]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                CNOT(q[0],q[2]);
                CNOT(q[1],q[2]);
                H(q[0]);
                H(q[1]);
                H(q[3]);
                H(q[4]);
                set q[1] = M(q[0]);
                set q[4] = M(q[3]);
                ResetAll(q);
            }
            return [q[1];q[4]];
        }
    }

}
