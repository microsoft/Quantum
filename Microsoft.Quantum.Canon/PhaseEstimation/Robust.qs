// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Convert;
    open Microsoft.Quantum.Extensions.Math;

    /// # Summary
    /// Performs the robust non-terative quantum phase estimation algorithm for a given oracle $U$ and eigenstate,
    /// and provides a single real-valued estimate of the phase with variance scaling at the Heisenberg limit.
    ///
    /// # Input
    /// ## oracle
    /// An operation implementing $U^m$ for given integer powers $m$. 
    /// ## targetState
    /// A quantum register that $U$ acts on. If it stores an eigenstate 
    /// $\ket{\phi}$ of $U$, then $U\ket{\phi} = e^{i\phi} \ket{\phi}$
    /// for $\phi\in(-\pi,\pi]$ an unknown phase.
    /// ## bitsPrecision
    /// This provides an estimate of $\phi$ with standard deviation
    /// $\sigma \le 2\pi / 2^\text{bitsPrecision}$ using a number of queries scaling like $\sigma \le 10.7 \pi / \text{# of queries}$.
    ///
    /// # Remarks
    /// In the limit of a large number of queries, Cramer-Rao lower bounds
    /// for the standard deviation of the estimate of $\phi$ satisfy
    /// $\sigma \ge 2 \pi / \text{# of queries}$.
    ///
    /// # References
    /// - Robust Calibration of a Universal Single-Qubit Gate-Set via Robust Phase Estimation
    ///   Shelby Kimmel, Guang Hao Low, Theodore J. Yoder
    ///   https://arxiv.org/abs/1502.02677
    operation RobustPhaseEstimation(bitsPrecision : Int, oracle : DiscreteOracle, targetState : Qubit[])  : Double
    {
        body {
            let alpha = 2.5;
            let beta = 0.5;
            mutable thetaEst = ToDouble(0);

            using (qubitAncilla = Qubit[1]) {
                let q = qubitAncilla[0];

                for (exponent in 0..bitsPrecision - 1) {

                    let power = 2 ^ (exponent);
                    mutable nRepeats = Ceiling(alpha * ToDouble(bitsPrecision - exponent) + beta);
                    if (nRepeats % 2 == 1) {
                        // Ensures that nRepeats is even.
                        set nRepeats = nRepeats + 1;
                    }

                    mutable pZero = ToDouble(0);
                    mutable pPlus = ToDouble(0);

                    for (idxRep in 0..nRepeats-1) {
                        for (idxExperiment in 0..1) {
                            // Divide rotation by power to cancel the multiplication by power in DiscretePhaseEstimationIteration
                            let rotation = PI() * ToDouble(idxExperiment) / 2.0 / ToDouble(power);
                            DiscretePhaseEstimationIteration(oracle , power , rotation, targetState, q);
                            let result = M(q);

                            if (result== Zero) {
                                if (idxExperiment == 0) {
                                    set pZero = pZero + 1.0;
                                }
                                elif (idxExperiment == 1) {
                                    set pPlus = pPlus + 1.0;
                                }
                            }
                            Reset(q);
                        }
                    }
                    let deltaTheta = ArcTan2(pPlus - ToDouble(nRepeats) / 2.0,  pZero - ToDouble(nRepeats) / 2.0);
                    let delta = RealMod( deltaTheta - thetaEst * ToDouble(power), 2.0 * PI(), - PI());
                    set thetaEst = thetaEst + delta / ToDouble(power);
                }
                Reset(q);
            }
            return thetaEst;
        }
    }

}
