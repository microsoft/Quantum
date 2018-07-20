namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation TeleportTest():(Result[])
    {
        body
        {
            mutable c = new Result[3];
            using(q = Qubit[3]){
				Rx(0.7,q[0]); 
				Ry(0.8,q[0]); 
				Rz(0.9,q[0]);
				H(q[1]);
				CNOT(q[1],q[2]);
				CNOT(q[0],q[1]);
				H(q[0]);
				set c[0] = M(q[0]);
				set c[1] = M(q[1]);
				if(c[0]==1){
					Z(q[2]);
				}
				if(c[1]==1){
					X(q[2]);
				}
				set c[2] = M(q[2]);
				ResetAll(q);
            }
            return [c[0];c[1];c[2]];
        }
    }
}
