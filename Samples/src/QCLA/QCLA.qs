namespace Quantum.QCLA {
    
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;
    // This file contains an implementation of the Quantum Carry Look-Ahead (QCLA) Circuit
    // Described in this paper:
    // https://arxiv.org/pdf/quant-ph/0406142.pdf

    // Inputs:
        // An n qubit register in an arbitrary state. 
        // An n qubit register in an arbitrary state.
        // An n+1 qubit state in 0 state.
    // Goal:
        // Computes a + b, stores the sum in s. The registers here are little endian. 
        // (That is, the least significant is in arr[0] for a Qubit register arr )
        // This function should preserve a and b's state.
    operation QCLA(a : Qubit[], b : Qubit[], s : Qubit[]) : Unit {
       
        // N needs to be >= 3 otherwise loops break inside the Section 3 code block (See end of section 3).
        //Handle them just with some basic RCA Circuits
        let N = Length(a);
        if (N == 1) {
            oneBitRCA(a,b,s);
            return ();
        } elif (N == 2) {
            twoBitRCA(a,b,s);
            return ();
        }

        //Otherwise break into the general case.
        for (i in 0 .. N-1) {
            CCNOT(a[i],b[i],s[i+1]);
        }

        for (i in 1 .. N-1) {
            CNOT(a[i],b[i]);
        }
        
        //Pass them to procedure described in section 3. Once this step is complete,
        //The array s will have the input carry bit for the sum of the a[i] and b[i].
        // for all i in [1, ... N) (there is no carry bit for the 0th position). 
        Section3(b, s, N);

        //This is the equivalent of setting s[i] = a[i] + b[i] +c[i] modulo 2 arithmetic
        // for i>0.
        for (i in 0 .. N-1) {
            CNOT(b[i], s[i]);
        }

        //we have to factor in a[0] into our sum, since we skipped that position.
        CNOT(a[0], s[0]);

        //reset the b array by undoing the CNOT operation we did above.
        for (i in 1 .. N-1 ) {
            CNOT(a[i], b[i]);
        }

    }

    // Runs the Carry Look-Ahead portion of the algorithm discussed in section 3 of the paper.
    operation Section3(pnot : Qubit[], G : Qubit[], N : Int) : Unit {
        mutable logN = (Log(ToDouble(N)))/(Log(2.0));
        mutable end = Floor(logN);
        using (x = Qubit[N - W(N) - end]) {
           
            //P Rounds
            let p = pnot + x;

            for (i in 1 .. end - 1) {
                pRound(N, i, p);
            }

            //G Rounds
            for (i in 1 .. end) {
                gRound(N, i, G, p);
            }

            // Using the properties of Log(ab) = Log(a) + Log(b)
            // Log(a/b) = Log(a) - Log(b) to reduce our operation of Log(2n/3)
            // into less costly addition, subtraction operations rather than division and multiplication.
            mutable cend = Floor(1.0 + logN - ((Log(3.0))/(Log(2.0))));

            //C Rounds
            for (i in cend .. 1) {
                cRound(N, i, G, p);
            }

            //P^-1 rounds
            for (i in 1 .. end - 1) {
                let k = end - i;
                pRound(N, k, p);
            }
        }

    }

    // This function returns the specified Qubit in our shared qubit register
    // at position i for round t of the P Round. This is used to keep the same
    // indexing as described by the paper.
    function P(p : Qubit[], i : Int, t : Int, n : Int) : Qubit {
        if (t == 0) {
            return p[i];
        }

        let offset = n * (2^(t-1) - 1) / 2^(t - 1) - (t - 1) + n; // Dont ask
        return p[offset + (i - 1)];
    }

    //Runs the t-th P round of the circuit.
    operation pRound(N: Int, t : Int, Pt : Qubit[]) : Unit {
        body(...) {
            let end = Floor(((ToDouble(N))/(PowD(2.0,ToDouble(t)))));
            for (i in 1 .. end - 1 ) {
                CCNOT(P(Pt, 2*i, t - 1, N), P(Pt, (2*i)+1, t - 1, N), P(Pt, i, t, N));
            }
        }
        adjoint auto;
    }

    // Computes one G round
    operation gRound(N : Int, t : Int, G: Qubit[], pt: Qubit[]) : Unit {
        body(...) {
            let end = Floor(((ToDouble(N))/(PowD(2.0,ToDouble(t)))));
            let twoTot = Round(PowD(2.0, ToDouble(t)));
            for (i in 1 .. end-1 ) {
                CCNOT(P(pt, 2*i+1, t - 1, N), G[twoTot*i + twoTot/2], G[twoTot * (i+1)]);
            }
        }
        adjoint auto;
    }

    // Runs one C round. For a formal description, see
    operation cRound(N : Int, t : Int, G: Qubit[], pt: Qubit[]) : Unit {
        let end = Floor(ToDouble((N - 2^(t - 1)))/ToDouble((2^t)));
        for (m in 1 .. end) {
            let g = m*2^t;
            let gDest = g + 2^(t - 1);
            let p = 2*m;
            CCNOT(G[g], P(pt, p, t - 1, N), G[gDest]);
        }
    }

    //Un computes the work of the P round
    operation pInvRound(N : Int, G: Qubit[], pt: Qubit[]) : Unit {

    }

    // This function returns the count of the number of ones 
    // in the binary expansion of N.
    function W(N : Int) : Int {
        mutable temp = N;
        mutable count = 0;
        repeat {
            set count = count + (temp &&& 1);
            set temp = temp >>> 1;

        } until (temp <= 0) fixup{}
        return count;
    }

    //----------------------------------------------------
    //-------------------- Edge Cases --------------------
    //----------------------------------------------------

    // Below is a rudimentary Ripple carry addition circuit 
    // For the edge case our QCLA circuit tries to add numbers of
    // Qubit count N <= 2. The formulas for computing the end of the P,G,C rounds
    // break. We assume little endian representation for our numbers. (That is, 
    // least signinifcant bit is arr[0] for a qubit registter)

    // Ripple carry addition for One bit numebers. Output stored in s.
    operation oneBitRCA(a : Qubit[], b : Qubit[], s : Qubit[]) : Unit {
        //Determine the 1's place.

        //We can also change this to not use ancilae , depending on the total cost of the of this algorithm.
        //We use it just for code reusability.
        using (scratch = Qubit()) {
            BitSum(a[0], b[0], scratch, s[0]);
            carryBit(a[0], b[0], scratch, s[1]);
        }
    }

    // two bit RCA circuit. This is the one clients call.
    // Takes in two two qubit numbers, a and b, and stores their sum in a 3
    // qubit 
    operation twoBitRCA(a : Qubit[], b : Qubit[], s : Qubit[]) : Unit {
        using (temp = Qubit[Length(s)]) {
            twoBitHelper(a,b,temp);
            //Copy out the answer into our register
            for (i in 0 .. Length(s) -1 ) {
                CNOT(temp[i], s[i]);
            }
            Adjoint twoBitHelper(a,b,temp);
        }
    }

    //Internal helper for two bit RCA circut. 
    // Here the reigsters are assumed little endian.
    operation twoBitHelper(a : Qubit[], b : Qubit[], s: Qubit[]) : Unit {
        body (...) {
            using (carry = Qubit()) {

                //Figure out the carry bit and sum of the 1's position
                CCNOT(a[0], b[0], carry);
                CNOT(a[0], s[0]);
                CNOT(b[0], s[0]);

                //Figure out the 2's position and carry.
                BitSum(a[1], b[1], carry, s[1]);
                carryBit(a[1], b[1], carry, s[2]);

                //reset the carry temporary carry qubit.
                CCNOT(a[0], b[0], carry);
            }
        }
        adjoint auto;
    }

    // Carry Bit for a,b and arbitrary carry in bits. Their carry bit is output in cout.
    operation carryBit(a : Qubit, b : Qubit, cin : Qubit, cout :  Qubit) : Unit {
        body(...) {
            CCNOT(a,b,cout);
            CCNOT(a,cin, cout);
            CCNOT(b,cin, cout);
        }

        adjoint auto;
    }

    // Figures out the sum of a bit a,b and input carry bit c. Stored in s.
    operation BitSum(a : Qubit, b : Qubit, c : Qubit, s : Qubit) : Unit{
        body (...) {
            CNOT(a, s);
            CNOT(b, s);
            CNOT(c, s);
        }
        adjoint auto;
    }
}
