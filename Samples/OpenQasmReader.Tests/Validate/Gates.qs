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

    operation GatesTest():()
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
