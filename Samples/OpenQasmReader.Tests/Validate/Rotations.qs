namespace Microsoft.Quantum.Samples.OpenQasmReader.Tests.Validate
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

    operation RotationsTest():(Result[])
    {
        body
        {
            mutable c = new Result[6];
            using(q = Qubit[6]){
				Rz(1.0,q[0]);
				Ry(2.0,q[1]);
				Rz(1.0,q[1]);
				Rx(3.0,q[2]);
				Ry(2.0,q[2]);
				Rz(1.0,q[2]);
				Rz(5.0,q[3]);
				Ry(6.0,q[4]);
				Rz(5.0,q[4]);
				Rx(7.0,q[5]);
				Ry(6.0,q[5]);
				Rz(5.0,q[5]);
				for(_idx in 0..Length(c)){
					set c[_idx] = M(q[_idx]);
				}
				ResetAll(q);
            }
            return [c[0];c[1];c[2];c[3];c[4];c[5]];
        }
    }

}
