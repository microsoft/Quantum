namespace CustomModAdd {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Numerics.Samples;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation Program () : Unit {

        let inputs1 = [3, 5, 3, 4, 5];
        let inputs2 = [5, 4, 6, 4, 1];
        let modulus = 7;
        let numBits = 4;

        let res = CustomModAdd(inputs1, inputs2, modulus, numBits);
        for (i in IndexRange(res)) {
            Message($"{inputs1[i]} + {inputs2[i]} mod {modulus} = {res[i]}.");        
        }
    }
}
