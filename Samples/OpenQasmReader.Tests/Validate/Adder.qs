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


    operation Unmaj(a:Qubit,b:Qubit,c:Qubit):()
    {
        body
        {
            CCNOT(a,b,c);
            CNOT(c,a);
            CNOT(a,b);
        }
    }


    operation Add4(a0:Qubit,a1:Qubit,a2:Qubit,a3:Qubit,b0:Qubit,b1:Qubit,b2:Qubit,b3:Qubit,cin:Qubit,cout:Qubit):()
    {
        body
        {
            Majority(cin,b0,a0);
            Majority(a0,b1,a1);
            Majority(a1,b2,a2);
            Majority(a2,b3,a3);
            CNOT(a3,cout);
            Unmaj(a2,b3,a3);
            Unmaj(a1,b2,a2);
            Unmaj(a0,b1,a1);
            Unmaj(cin,b0,a0);
        }
    }


    operation AdderTest():(Result[])
    {
        body
        {
            mutable ans = new Result[8];
            mutable carryout = new Result[1];
            using(carry = Qubit[2]){
				using(a = Qubit[8]){
					using(b = Qubit[8]){
						X(a[0]);
						ApplyToEach(X,b);
						X(b[6]);
						Add4(a[0],a[1],a[2],a[3],b[0],b[1],b[2],b[3],carry[0],carry[1]);
						Add4(a[4],a[5],a[6],a[7],b[4],b[5],b[6],b[7],carry[1],carry[0]);
						set ans[0] = M(b[0]);
						set ans[1] = M(b[1]);
						set ans[2] = M(b[2]);
						set ans[3] = M(b[3]);
						set ans[4] = M(b[4]);
						set ans[5] = M(b[5]);
						set ans[6] = M(b[6]);
						set ans[7] = M(b[7]);
						set carryout[0] = M(carry[0]);
						ResetAll(carry);
						ResetAll(a);
						ResetAll(b);
					}
				}
            }
            return [ans[0];ans[1];ans[2];ans[3];ans[4];ans[5];ans[6];ans[7];carryout[0]];
        }
    }
}
