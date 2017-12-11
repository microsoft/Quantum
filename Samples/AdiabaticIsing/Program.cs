// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the 
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries 
// and Samples. See LICENSE in the project root for license information.

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


            #region Basic Definitions

            // We start by loading the simulator that we will use to run our Q# operations.
            var qsim = new QuantumSimulator();

            // Each site of the Ising model is simulated using a single qubit. 
            var nSites = 9;

            // In all the following, we use this coefficient for coupling to the transverse
            // field.
            var hxCoeff = 1.0;

            // For now, we also use this coefficient for coupling between sites.
            var jCCoeff = 1.0;

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

            // For diagnostic purposes, before we proceed to the next step, we'll print
            // out a description of the parameters we just defined.
            Console.WriteLine("\nIsing model parameters:");
            Console.WriteLine(
                $"\t{nSites} sites\n" +
                $"\t{hxCoeff} transverse field coefficient\n" +
                $"\t{jCCoeff} two-site coupling coefficient\n" +
                $"\t{adiabaticTime} time-interval of interpolation\n" +
                $"\t{trotterStepSize} simulation time step \n" +
                $"\t{trotterOrder} order of integrator\n");

            Console.WriteLine("Let us consider the results of fast non-adiabatic evolution from the transverse Hamiltonian to the coupling Hamiltonian. Observe that the zeros and one occur almost randomly.");

            // We measure each site after this time-dependent simulation, and repeat
            // 10 times as the output is probabilistic.
            for (int rep = 0; rep < 10; rep++)
            {
                // We call the Q# operation we wrote in the .qs file and return its results as a C# array.
                var data = Ising1DAdiabaticAndMeasureManual.Run(qsim, nSites, hxCoeff, jCCoeff, adiabaticTime, trotterStepSize, trotterOrder).Result.ToArray();
                // We now print the results of measurement.
                Console.Write($"State: {string.Join(", ", data.Select(x=>x.ToString()).ToArray())} \n");
            }

            // Let now interpolate between these Hamiltonians more slowly.
            adiabaticTime = 10.0;
            Console.WriteLine("\nIsing model parameters:");
            Console.WriteLine(
                $"\t{nSites} sites\n" +
                $"\t{hxCoeff} transverse field coefficient\n" +
                $"\t{jCCoeff} two-site coupling coefficient\n" +
                $"\t{adiabaticTime} time-interval of interpolation\n" +
                $"\t{trotterStepSize} simulation time step \n" +
                $"\t{trotterOrder} order of integrator\n");

            Console.WriteLine("Let us now slow down the evolution. Observe that there is now a stronger correlation in the measurement results on neighbouring sites.");
            for (int rep = 0; rep < 10; rep++)
            {

                
                var data = Ising1DAdiabaticAndMeasureManual.Run(qsim, nSites, hxCoeff, jCCoeff, adiabaticTime, trotterStepSize, trotterOrder).Result.ToArray();
                Console.Write($"State: {string.Join(", ", data.Select(x => x.ToString()).ToArray())} \n");
            }

            // We may also study anti-ferromagnetic coupling by changing the sign of jCCoeff.
            jCCoeff = -1.0;
            Console.WriteLine("\nIsing model parameters:");
            Console.WriteLine(
                $"\t{nSites} sites\n" +
                $"\t{hxCoeff} transverse field coefficient\n" +
                $"\t{jCCoeff} two-site coupling coefficient\n" +
                $"\t{adiabaticTime} time-interval of interpolation\n" +
                $"\t{trotterStepSize} simulation time step \n" +
                $"\t{trotterOrder} order of integrator\n");

            Console.WriteLine("Observe that there is now a strong anti-correlation in the measurement results on neighbouring sites.");
            // Let us use this opportunity to test the adiabatic evolution as written using
            // more library functions.
            for (int rep = 0; rep < 10; rep++)
            {
               var data = Ising1DAdiabaticAndMeasureBuiltIn.Run(qsim, nSites, hxCoeff, jCCoeff, adiabaticTime, trotterStepSize, trotterOrder).Result.ToArray();
                Console.Write($"State: {string.Join(", ", data.Select(x => x.ToString()).ToArray())} \n");
            }

            Console.ReadLine();

            #endregion
        }
    }
}
