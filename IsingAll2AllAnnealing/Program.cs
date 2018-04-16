// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Samples.Ising
{
    class Program
    {
        static void Main(string[] args)
        {
            #region Ising spin glass data & Basic Definitions

            // Initial h coupling term
            var hStart = 1.0;
            
            // Final j coupling term muliplicative modifier
            var jEnd = 1.0;

            // Connectivity of spin glass ZZ terms (spin A, spin B, j coupling)
            var j = 1.0;
            var jCouplingData = new(Int64, Int64, Double)[]
            {
                (0,1,j), (1,2,j), (2,3,j), (2,3,j), (2,3,j)
            };

            // We start by loading the simulator that we will use to run our Q# operations.
            var qsim = new QuantumSimulator();

            // As we are using a Trotter–Suzuki decomposition as our simulation algorithm,
            // we will need to pick a timestep for the simulation, and the order of the
            // integrator. The optimal timestep needs to be determined empirically, and
            // we find that the following choice works well enough.
            var trotterStepSize = 0.1;
            var trotterOrder = 2;

            // Let us now simulate time-evolution by interpolating between the initial
            // Hamiltonian with the |+〉 product state as the ground state, and the target
            // Hamiltonian. For the uniform Ising model, the ground state of the target
            // Hamiltonian should have all spins pointing in the same direction. If we
            // interpolate between these Hamiltonians slowly enough, the initial ground
            // state will continuously deform into the ground state of the target
            // Hamiltonian

            // Let us consider the situation where we interpolate between these Hamiltonians
            // too quickly.
            var adiabaticTime = 0.1;

            #endregion

            #region Ising model simulations
            // Convert j CouplingData to format Q# can consume.
            QArray<(Int64, Int64, Double)> jCouplingDataFormatted = new QArray<(Int64, Int64, Double)>();
            // Number of spins
            Int64 nSites = 0;
            foreach (var jCoupling in jCouplingData)
            {
                var (spinA, spinB, coff) = jCoupling;
                var maxSpinIdx = Math.Max(spinA, spinB) + 1;
                nSites = Math.Max(nSites, maxSpinIdx);

                jCouplingDataFormatted.Add(jCoupling);
            }

            // For diagnostic purposes, before we proceed to the next step, we'll print
            // out a description of the parameters we just defined.
            Console.WriteLine("\nIsing model parameters:");
            Console.WriteLine(
                $"\t{nSites} sites\n" +
                //$"\t{hxCoeff} transverse field coefficient\n" +
                //$"\t{jCCoeff} two-site coupling coefficient\n" +
                $"\t{adiabaticTime} time-interval of interpolation\n" +
                $"\t{trotterStepSize} simulation time step \n" +
                $"\t{trotterOrder} order of integrator\n");

            Console.WriteLine("Let us consider the results of fast non-adiabatic evolution from the transverse Hamiltonian to the coupling Hamiltonian. Observe that the zeros and one occur almost randomly.");

       
            for (int rep = 0; rep < 10; rep++)
            {
               var data = IsingAll2AllAdiabaticAndMeasure.Run(qsim, nSites, hStart, jEnd, jCouplingDataFormatted, adiabaticTime, trotterStepSize, trotterOrder).Result.ToArray();
                Console.Write($"State: {string.Join(", ", data.Select(x => x.ToString()).ToArray())} \n");
            }

            Console.WriteLine("Press Enter to continue...");
            Console.ReadLine();

            #endregion
        }
    }
}
