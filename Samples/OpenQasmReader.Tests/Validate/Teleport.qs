// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation Teleport():(Result[])
    {
        body
        {
            mutable c0 = new Result[1];
            mutable c1 = new Result[1];
            mutable c2 = new Result[1];
            using(q = Qubit[3]){
                Rx(0.7,q[0]);
                Ry(0.8,q[0]);
                Rz(0.9,q[0]);
                H(q[1]);
                CNOT(q[1],q[2]);
                CNOT(q[0],q[1]);
                H(q[0]);
                set c0[0] = M(q[0]);
                set c1[0] = M(q[1]);
                if(ResultAsInt(c0)==1){
                    Z(q[2]);
                }
                if(ResultAsInt(c1)==1){
                    X(q[2]);
                }
                set c2[0] = M(q[2]);
                ResetAll(q);
            }
            return [c0[0];c1[0];c2[0]];
        }
    }

}
