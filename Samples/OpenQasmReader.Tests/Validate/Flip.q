namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation FlipTest():(Result[])
    {
        body
        {
            mutable c = new Result[5];
            using(q = Qubit[5]){
            X(q[0]);
            X(q[1]);
            I(q[2]);
            H(q[2]);
            CNOT(q[1],q[2]);
            (Adjoint T)(q[2]);
            CNOT(q[0],q[2]);
            T(q[2]);
            CNOT(q[1],q[2]);
            (Adjoint T)(q[2]);
            CNOT(q[0],q[2]);
            T(q[1]);
            T(q[2]);
            H(q[2]);
            CNOT(q[1],q[2]);
            H(q[1]);
            H(q[2]);
            CNOT(q[1],q[2]);
            H(q[1]);
            H(q[2]);
            CNOT(q[1],q[2]);
            CNOT(q[0],q[2]);
            T(q[0]);
            (Adjoint T)(q[2]);
            CNOT(q[0],q[2]);
            set c[0] = M(q[0]);
            set c[1] = M(q[1]);
            set c[2] = M(q[2]);
            ResetAll(q);
            }
            return [c[0];c[1];c[2]];
        }
    }
}