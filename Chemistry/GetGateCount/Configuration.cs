// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// This file defines several structures used for configuring how the rest
// of the sample runs.

using System;

namespace Microsoft.Quantum.Chemistry.Samples
{

    /// <summary>
    /// Configuration data for Hamiltonian simulation algorithm
    /// </summary>
    public struct HamiltonianSimulationConfig
    {
        /// <summary>
        /// Choice of Hamiltonian simulation algorithm
        /// </summary>
        public HamiltonianSimulationAlgorithm hamiltonianSimulationAlgorithm;
        /// <summary>
        /// Configuration for <see cref="HamiltonianSimulationAlgorithm.ProductFormula"/>.
        /// </summary>
        public ProductFormulaConfig productFormulaConfig;
        /// <summary>
        /// Configuration for <see cref="HamiltonianSimulationAlgorithm.Qubitization"/>.
        /// </summary>
        public QubitizationConfig qubitizationConfig;
        /// <summary>
        /// Hamiltonian simulation algorithm configuration constructor.
        /// </summary>
        /// <param name="setProductFormulaConfig">Product formula configuration</param>
        public HamiltonianSimulationConfig(ProductFormulaConfig setProductFormulaConfig = new ProductFormulaConfig())
        {
            hamiltonianSimulationAlgorithm = HamiltonianSimulationAlgorithm.ProductFormula;
            productFormulaConfig = setProductFormulaConfig;
            // Default settings for all other parameters
            qubitizationConfig = new QubitizationConfig();
        }
        /// <summary>
        /// Hamiltonian simulation algorithm configuration constructor.
        /// </summary>
        /// <param name="setQubitizationConfig">Qubitization formula configuration</param>
        public HamiltonianSimulationConfig(QubitizationConfig setQubitizationConfig = new QubitizationConfig())
        {
            hamiltonianSimulationAlgorithm = HamiltonianSimulationAlgorithm.Qubitization;
            qubitizationConfig = setQubitizationConfig;
            // Default settings for all other parameters
            productFormulaConfig = new ProductFormulaConfig();
        }
        /// <summary>
        /// Enumeration type for choice of Hamiltonian simulation algorithm
        /// </summary>
        public enum HamiltonianSimulationAlgorithm
        {
            ProductFormula,
            Qubitization
        };
        /// <summary>
        /// Configuration data for product formula simulation algorithm
        /// </summary>
        public struct ProductFormulaConfig
        {
            /// <summary>
            /// Order of product formula integrator.
            /// </summary>
            public Int64 Order;
            /// <summary>
            /// Step-size of product formula
            /// </summary>
            public Double StepSize;
            /// <summary>
            /// Product formula configuration constructor.
            /// </summary>
            /// <param name="setStepSize">Step size of integrator</param>
            /// <param name="setOrder">Order of integrator</param>
            public ProductFormulaConfig(Double setStepSize, Int64 setOrder = 1)
            {
                Order = setOrder;
                if (setOrder > 2)
                {
                    throw new System.NotImplementedException($"Product formulas of order > 2 not implemented.");
                }
                StepSize = setStepSize;
            }
        };
        /// <summary>
        /// Configuration data for Qubitization simulation algorithm
        /// </summary>
        public struct QubitizationConfig
        {
            /// <summary>
            /// Choice of quantum state preparation
            /// </summary>
            public QubitizationStatePrep qubitizationStatePrep;
            /// <summary>
            /// Qubitization configuration constructor.
            /// </summary>
            /// <param name="setQubitizationStatePrep">Choice of quantum state preparation algorithm</param>
            public QubitizationConfig(QubitizationStatePrep setQubitizationStatePrep = QubitizationStatePrep.MinimizeQubitCount)
            {
                qubitizationStatePrep = setQubitizationStatePrep;
            }
            /// <summary>
            /// Enumeration type for choice of quantum state preparation.
            /// </summary>
            public enum QubitizationStatePrep
            {
                MinimizeQubitCount,
                MinimizeTGateCount
            }

        }
    }
}