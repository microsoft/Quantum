namespace Microsoft.Quantum.Arithmetic {
    operation MeasureBigInt(qs: LittleEndian) : BigInt {
        mutable result = ToBigInt(0);
        mutable i = 0;
        for (q in qs!) {
            if (Measure([PauliZ], [q]) == One) {
                set result = result + (ToBigInt(1) <<< i);
            }
            set i = i + 1;
        }
        return result;
    }

    operation MeasureSignedBigInt(qs: LittleEndian) : BigInt {
        mutable result = MeasureBigInt(qs);
        if (result >= ToBigInt(1) <<< (Length(qs!) - 1)) {
            set result = result - (ToBigInt(1) <<< Length(qs!));
        }
        return result;
    }

    operation MeasureResetBigInt(qs: LittleEndian) : BigInt {
        mutable result = ToBigInt(0);
        mutable i = 0;
        for (q in qs!) {
            if (Measure([PauliZ], [q]) == One) {
                set result = result + (ToBigInt(1) <<< i);
                X(q);
            }
            set i = i + 1;
        }
        return result;
    }

    operation ForceMeasureResetBigInt(qs: LittleEndian, expectedValue: BigInt) : BigInt {
        mutable result = ToBigInt(0);
        mutable i = 0;
        for (q in qs!) {
            AssertProb([PauliZ], [q], ((expectedValue >>> i) &&& ToBigInt(1)) != ToBigInt(0) ? One | Zero, 1.0, "", 0.01);
            if (Measure([PauliZ], [q]) == One) {
                set result = result + (ToBigInt(1) <<< i);
                X(q);
            }
            set i = i + 1;
        }
        return result;
    }
}
