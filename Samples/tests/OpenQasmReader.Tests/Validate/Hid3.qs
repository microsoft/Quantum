// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation Hid3():(Result[])
    {
        body
        {
            mutable c = new Result[4];
            using(q = Qubit[5]){
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                X(q[1]);
                X(q[2]);
                H(q[2]);
                CNOT(q[1],q[2]);
                H(q[2]);
                X(q[1]);
                X(q[2]);
                CNOT(q[4],q[2]);
                H(q[2]);
                H(q[4]);
                CNOT(q[4],q[2]);
                H(q[2]);
                H(q[4]);
                CNOT(q[4],q[2]);
                H(q[2]);
                CNOT(q[3],q[2]);
                H(q[2]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[2]);
                CNOT(q[3],q[2]);
                H(q[2]);
                CNOT(q[4],q[2]);
                H(q[2]);
                H(q[4]);
                CNOT(q[4],q[2]);
                H(q[2]);
                H(q[4]);
                CNOT(q[4],q[2]);
                H(q[2]);
                CNOT(q[1],q[2]);
                H(q[2]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                set c[0] = M(q[1]);
                set c[1] = M(q[2]);
                set c[2] = M(q[3]);
                set c[3] = M(q[4]);
                ResetAll(q);
            }
            return [c[0];c[1];c[2];c[3]];
        }
    }
}
