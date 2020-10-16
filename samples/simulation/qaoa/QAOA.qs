namespace Microsoft.Quantum.Samples.QAOA {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// This operation applies the X-rotation to each qubit. We can think of it as time 
    /// evolution induced by applying a Hamiltonian that sums over all X rotations.
    ///
    /// # Description
    /// The driver Hamiltonian is defined as:
    ///    H = - \sum_i X_i for time t.
    ///
    /// # Input
    /// ## time
    /// Time passed in evolution of X rotation
    /// ## target
    /// Target qubit register
    operation ApplyDriverHamiltonian(time: Double, target: Qubit[]) : Unit is Adj + Ctl {
        ApplyToEachCA(Rx(-2.0 * time, _), target);
    }

    /// # Summary
    /// This applies the Z-rotation according to the instance Hamiltonian. 
    /// We can think of it as Hamiltonian time evolution for time t induced
    /// by an Ising Hamiltonian. The Ising Hamiltonian sums over all connected
    /// pairs of Pauli-Z operations Z_i and Z_j scaled by a factor J_ij, plus 
    /// the sum over all Z_i scaled by a factor h_i.
    ///
    /// # Description
    /// The Ising Hamiltonian is defined as:
    ///     $\sum_ij J_ij Z_i Z_j + \sum_i h_i Z_i$.
    ///
    /// # Input
    /// ## time
    /// Time point in evolution.
    /// ## weights
    /// Ising magnetic field or "weights" encoding the constraints of our
    /// traveling Santa problem.
    /// ## coupling
    /// Ising coupling term or "penalty" encoding the constraints of our
    /// traveling Santa problem.
    /// ## target
    /// Qubit register that encodes the Spin values in the Ising Hamiltonian.
    operation ApplyInstanceHamiltonian(
        numSegments : Int,
        time : Double, 
        weights : Double[], 
        coupling : Double[],
        target : Qubit[]
    ) : Unit {
        using (auxiliary = Qubit()) {
            for ((h, qubit) in Zipped(weights, target)) {
                Rz(2.0 * time * h, qubit);
            }
            for (i in 0..5) {
                for (j in i + 1..5) {
                    within {
                        CNOT(target[i], auxiliary);
                        CNOT(target[j], auxiliary);
                    } apply {
                        Rz(2.0 * time * coupling[numSegments * i + j], auxiliary);
                    }
                }
            }
        }
    }

    /// # Summary
    /// Calculate Hamiltonian parameters based on the given costs and penalty.
    ///
    /// # Input
    /// ## segmentCosts
    /// Cost values of each segment.
    /// ## penalty
    /// Penalty for cases that don't meet constraints.
    ///
    /// # Output
    /// ## weights
    /// Hamiltonian parameters or "weights" as an array where each element corresponds 
    /// to a parameter h_j for qubit state j.
    /// ## numSegments
    /// Number of segments in the graph that describes possible paths.
    function HamiltonianWeights(
        segmentCosts : Double[], 
        penalty : Double, 
        numSegments : Int
    ) : Double[] {
        mutable weights = new Double[numSegments];
        for (i in 0..numSegments - 1) {
            set weights w/= i <- 4.0 * penalty - 0.5 * segmentCosts[i];
        }
        return weights;
    }

    /// # Summary
    /// Calculate Hamiltonian coupling parameters based on the given penalty.
    ///
    /// # Input
    /// ## penalty
    /// Penalty for cases that don't meet constraints.
    /// ## numSegments
    /// Number of segments in the graph that describes possible paths.
    ///
    /// # Output
    /// ## coupling
    /// Hamiltonian coupling parameters as an array, where each element corresponds
    /// to a parameter J_ij between qubit states i and j.
    function HamiltonianCouplings(penalty : Double, numSegments : Int) : Double[] {
        // Calculate Hamiltonian coupling parameters based on the given costs and penalty
        // Most elements of J_ij equal 2*penalty, so set all elements to this value, 
        // then overwrite the exceptions. This is currently implemented for the
        // example with 6 segments.
        EqualityFactI(numSegments, 6, 
            "Currently, HamiltonianCouplings only supports given constraints for 6 segments."
        );
        return ConstantArray(numSegments * numSegments, 2.0 * penalty)
            w/ 2 <- penalty
            w/ 9 <- penalty
            w/ 29 <- penalty;
    }
    
    /// # Summary
    /// Perform the QAOA algorithm for this Ising Hamiltonian
    ///
    /// # Input
    /// ## numSegments
    /// Number of segments in graph
    /// ## weights
    /// Instance Hamiltonian parameters or "weights" as an array where each 
    /// element corresponds to a parameter h_j for qubit state j.
    /// ## couplings
    /// Instance Hamiltonian coupling parameters as an array, where each 
    /// element corresponds to a parameter J_ij between qubit states i and j.
    /// ## timeX
    /// Time evolution for PauliX operations
    /// ## timeZ
    /// Time evolution for PauliX operations
    operation PerformQAOA(
            numSegments : Int, 
            weights : Double[], 
            couplings : Double[], 
            timeX : Double[], 
            timeZ : Double[]
    ) : Bool[] {
        EqualityFactI(Length(timeX), Length(timeZ), "timeZ and timeX are not the same length");

        // Run the QAOA circuit
        mutable result = new Bool[numSegments];
        using (x = Qubit[numSegments]) {
            ApplyToEach(H, x); // prepare the uniform distribution
            for ((tz, tx) in Zipped(timeZ, timeX)) {
                ApplyInstanceHamiltonian(numSegments, tz, weights, couplings, x); // do Exp(-i H_C tz)
                ApplyDriverHamiltonian(tx, x); // do Exp(-i H_0 tx)
            }
            return ResultArrayAsBoolArray(MultiM(x)); // measure in the computational basis
        }
    }

    /// # Summary
    /// Calculate the total cost for the given result.
    ///
    /// # Input
    /// ## segmentCosts
    /// Array of costs per segment
    /// ## usedSegments
    /// Array of which segments are used
    ///
    /// # Output
    /// ## finalCost
    /// Calculated cost of given path
    function CalculatedCost(segmentCosts : Double[], usedSegments : Bool[]) : Double {
        mutable finalCost = 0.0;
        for ((cost, segment) in Zipped(segmentCosts, usedSegments)) {
            set finalCost += segment ? cost | 0.0;
        }
        return finalCost;
    }

    /// # Summary
    /// Final check to determine if the used segments satisfy our known 
    /// constraints. This function is implemented to consider a graph with 6 
    /// segments and three valid connected paths.
    ///
    /// # Input
    /// ## numSegments
    /// Number of segments in the graph
    /// ## usedSegments
    /// Array of which segments were used
    ///
    /// # Output
    /// ## output
    /// Boolean value whether the conditions are satisfied.
    function IsSatisfactory(numSegments: Int, usedSegments : Bool[]) : Bool {
        EqualityFactI(numSegments, 6, 
            "Currently, IsSatisfactory only supports constraints for 6 segments."
        );
        mutable hammingWeight = 0;
        for (segment in usedSegments) {
            set hammingWeight += segment ? 1 | 0;
        }
        if (hammingWeight != 4 
            or usedSegments[0] != usedSegments[2] 
            or usedSegments[1] != usedSegments[3] 
            or usedSegments[4] != usedSegments[5]) {
            return false;
        }
        return true;
    }

    /// # Summary
    /// Run QAOA for a given number of trials on 6 qubits. This sample is based 
    /// on the Traveling Santa Problem outlined here: 
    ///     http://quantumalgorithmzoo.org/traveling_santa/.
    /// Reports on the best itinerary for the Traveling Santa Problem and how 
    /// many of the runs resulted in the answer. This should typically return 
    /// the optimal solution roughly 71% of the time.
    /// 
    /// # Input
    /// ## numTrials
    /// Number of trials to run the QAOA algorithm for.
    @EntryPoint()
    operation RunQAOATrials(numTrials : Int) : Unit {
        let penalty = 20.0;
        let segmentCosts = [4.70, 9.09, 9.03, 5.70, 8.02, 1.71];
        let timeX = [0.619193, 0.742566, 0.060035, -1.568955, 0.045490];
        let timeZ = [3.182203, -1.139045, 0.221082, 0.537753, -0.417222];
        let limit = 1E-6;
        let numSegments = 6;

        mutable bestCost = 100.0 * penalty;
        mutable bestItinerary = [false, false, false, false, false];
        mutable successNumber = 0;

        let weights = HamiltonianWeights(segmentCosts, penalty, numSegments);
        let couplings = HamiltonianCouplings(penalty, numSegments);

        for (trial in 0..numTrials) {
            let result = PerformQAOA(
                numSegments, 
                weights, 
                couplings, 
                timeX, 
                timeZ
            );
            let cost = CalculatedCost(segmentCosts, result);
            let sat = IsSatisfactory(numSegments, result);
            Message($"result = {result}, cost = {cost}, satisfactory = {sat}");
            if (sat) {
                if (cost < bestCost - limit) {
                    // New best cost found - update
                    set bestCost = cost;
                    set bestItinerary = result;
                    set successNumber = 1;
                } elif (AbsD(cost - bestCost) < limit) {
                    set successNumber += 1;
                }
            }
        }
        let runPercentage = IntAsDouble(successNumber) * 100.0 / IntAsDouble(numTrials);
        Message("Simulation is complete\n");
        Message($"Best itinerary found: {bestItinerary}, cost = {bestCost}");
        Message($"{runPercentage}% of runs found the best itinerary\n");
    }
}
