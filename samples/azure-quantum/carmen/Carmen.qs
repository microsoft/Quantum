namespace Microsoft.Quantum.Samples {
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    operation PickRandomCityIdx(max: Int) : Int {
        Message($"Sampling a random number between 0 and {max}: ");
        let idxMarked = SampleRandomNumberInRange(max);
        Message($"{idxMarked}");
        return idxMarked;
    }

    @EntryPoint()
    operation FindCarmen() : Unit {
        let cities = [
            "London",
            "Addis Ababa",
            "Rio de Janeiro",
            "Hong Kong",
            "Atlanta",
            "Moscow",
            "Johannesburg"
        ];
        let numCities = Length(cities);
        let nQubits = BitSizeI(numCities);
        let idxMarked = PickRandomCityIdx(numCities-1);
        let city = cities[idxMarked];
        let applyOracle = ApplyControlledOnInt(idxMarked, X, _, _);
        let result = applyGroverSearch(nQubits, applyOracle);
        let resultIdx = ResultArrayAsInt(result);
        let resultCity = cities[resultIdx];

        Message($"Carmen is in {city}. Grover found: {resultCity}.");
    }

}
