// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation Hadamard():(Result[])
    {
        body
        {
            mutable c = new Result[1];
            using(q = Qubit[1]){
                H(q[0]);
                set c[1] = M(q[0]);
                ResetAll(q);
            }
            return [c[1]];
        }
    }
}
