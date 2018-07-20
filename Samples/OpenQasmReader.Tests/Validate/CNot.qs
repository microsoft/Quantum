namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation CNotTest():(Result[])
    {
        body
        {
            mutable c = new Result[2];
            using(q = Qubit[2]){
            H(q[0]);
            CNOT(q[0],q[1]);
            for(_idx in 0..Length(c)){
                set c[_idx] = M(q[_idx]);
            }
            ResetAll(q);
            }
            return [c[0];c[1]];
        }
    }
}
