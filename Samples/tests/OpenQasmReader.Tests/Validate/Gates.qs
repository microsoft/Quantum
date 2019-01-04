// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation Majority(a:Qubit,b:Qubit,c:Qubit):()
    {
        body
        {
                CNOT(c,b);
                CNOT(c,a);
                CCNOT(a,b,c);
        }
    }

    operation Gates():()
    {
        body
        {
            using(q = Qubit[3]){
                Majority(q[0],q[1],q[2]);
                ResetAll(q);
            }
        }
    }
}
