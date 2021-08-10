﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System;
using System.Linq;
using static System.Math;

namespace Microsoft.Quantum.Samples.DatabaseSearch
{
    
    class Program
    {

        static void Main(string[] args)
        {
            #region Setup

            // We begin by defining a quantum simulator to be our target
            // machine.
            var sim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true);

            #endregion

            #region Random Database Search with Manual Oracle Definitions

            // Let us investigate the success probability of classical random search.
            // This corresponds to the case where we only prepare the start state, and
            // do not perform any Grover iterates to amplify the marked subspace.
            var nIterations = 0;

            // We now define the size `N` = 2^n of the database to searched in terms of 
            // number of qubits `n`. 
            var nDatabaseQubits = 3;
            var databaseSize = Pow(2.0, nDatabaseQubits);

            // We now execute the classical random search and verify that the success 
            // probability matches the classical result of 1/N. Let us repeat 100
            // times to collect enough statistics.
            var classicalSuccessProbability = 1.0 / databaseSize;
            var repeats = 1000;
            var successCount = 0;

            Console.Write(
                $"Classical random search for marked element in database.\n" +
                $"  Database size: {databaseSize}.\n" +
                $"  Success probability:  {classicalSuccessProbability}\n\n");



            foreach (var idxAttempt in Enumerable.Range(0, repeats))
            {
                // Each operation has a static method called Run which takes a simulator as
                // an argument, along with all the arguments defined by the operation itself.  
                var task = ApplyQuantumSearch.Run(sim, nIterations, nDatabaseQubits);
                
                // We extract the return value of the operation by getting the Results property.
                var data = task.Result;

                // Extract the marked qubit state
                var markedQubit = data.Item1;
                var databaseRegister = data.Item2.ToArray();

                successCount += markedQubit == Result.One ? 1 : 0;

                // Print the results of the search every 100 attempts
                if ((idxAttempt + 1) % 100 == 0)
                {

                    Console.Write(
                        $"Attempt {idxAttempt}. " +
                        $"Success: {markedQubit},  " +
                        $"Probability: {Round((double)successCount / ((double)idxAttempt + 1),3)} " +
                        $"Found database index {string.Join(", ", databaseRegister.Select(x => x.ToString()).ToArray())} \n");
                }
            }

            #endregion


            #region Quantum Database Search with Manual Oracle Definitions

            // Let us investigate the success probability of the quantum search.
            
            // We define the size `N` = 2^n of the database to searched in terms of 
            // number of qubits `n`. 
            nDatabaseQubits = 6;
            databaseSize = Pow(2.0, nDatabaseQubits);

            // We now perform Grover iterates to amplify the marked subspace.
            nIterations = 3;

            // Number of queries to database oracle.
            var queries = nIterations * 2 + 1;

            // We now execute the quantum search and verify that the success 
            // probability matches the theoretical prediction. 
            classicalSuccessProbability = 1.0 / databaseSize;
            var quantumSuccessProbability = Pow(Sin((2.0 * (double)nIterations + 1.0) * Asin(1.0 / Sqrt(databaseSize))),2.0);
            repeats = 100;
            successCount = 0;

            Console.Write(
                $"\n\nQuantum search for marked element in database.\n" +
                $"  Database size: {databaseSize}.\n" +
                $"  Classical success probability: {classicalSuccessProbability}\n" +
                $"  Queries per search: {queries} \n" +
                $"  Quantum success probability: {quantumSuccessProbability}\n\n");



            foreach (var idxAttempt in Enumerable.Range(0, repeats))
            {
                // Each operation has a static method called Run which takes a simulator as
                // an argument, along with all the arguments defined by the operation itself.  
                var task = ApplyQuantumSearch.Run(sim, nIterations, nDatabaseQubits);

                // We extract the return value of the operation by getting the Results property.
                var data = task.Result;

                // Extract the marked qubit state
                var markedQubit = data.Item1;
                var databaseRegister = data.Item2.ToArray();

                successCount += markedQubit == Result.One ? 1 : 0;

                // Print the results of the search every 10 attempts
                if ((idxAttempt + 1) % 10 == 0)
                {
                    var empiricalSuccessProbability = Round((double)successCount / ((double)idxAttempt + 1), 3);

                    // This is how much faster the quantum algorithm performs on average
                    // over the classical search.
                    var speedupFactor = Round(empiricalSuccessProbability / classicalSuccessProbability / (double)queries, 3);

                    Console.Write(
                        $"Attempt {idxAttempt}. " +
                        $"Success: {markedQubit},  " +
                        $"Probability: {empiricalSuccessProbability} " +
                        $"Speedup: {speedupFactor} " +
                        $"Found database index {string.Join(", ", databaseRegister.Select(x => x.ToString()).ToArray())} \n");
                }
            }

            #endregion


            #region Multiple Element Quantum Database Search with the Canon

            // Let us investigate the success probability of the quantum search with multiple
            // marked elements.

            // We define the size `N` = 2^n of the database to searched in terms of 
            // number of qubits `n`. 
            nDatabaseQubits = 8;
            databaseSize = Pow(2.0, nDatabaseQubits);

            // We define the marked elements. These must be smaller than `databaseSize`.
            var markedElements = new long[] { 0, 39, 101, 234 };
            var nMarkedElements = markedElements.Length;
            


            // We now perform Grover iterates to amplify the marked subspace.
            nIterations = 3;

            // Number of queries to database oracle.
            queries = nIterations * 2 + 1;

            // We now execute the quantum search and verify that the success 
            // probability matches the theoretical prediction. 
            classicalSuccessProbability = (double)(nMarkedElements) / databaseSize;
            quantumSuccessProbability = Pow(Sin((2.0 * (double)nIterations + 1.0) * Asin(Sqrt(nMarkedElements) / Sqrt(databaseSize))), 2.0);
            repeats = 10;
            successCount = 0;

            Console.Write(
                $"\n\nQuantum search for marked element in database.\n" +
                $"  Database size: {databaseSize}.\n" +
                $"  Marked elements: {string.Join(",", markedElements.Select(x => x.ToString()).ToArray())}" +
                $"  Classical success probability: {classicalSuccessProbability}\n" +
                $"  Queries per search: {queries} \n" +
                $"  Quantum success probability: {quantumSuccessProbability}\n\n");



            foreach (var idxAttempt in Enumerable.Range(0, repeats))
            {
                // Each operation has a static method called Run which takes a simulator as
                // an argument, along with all the arguments defined by the operation itself.  
                var task = ApplyGroverSearch.Run(sim, new QArray<long>(markedElements), nIterations, nDatabaseQubits);

                // We extract the return value of the operation by getting the Results property.
                var data = task.Result;

                // Extract the marked qubit state
                var markedQubit = data.Item1;
                var databaseRegister = data.Item2;

                successCount += markedQubit == Result.One ? 1 : 0;

                // Print the results of the search every 1 attempt
                if ((idxAttempt + 1) % 1 == 0)
                {
                    var empiricalSuccessProbability = Round((double)successCount / ((double)idxAttempt + 1), 3);

                    // This is how much faster the quantum algorithm performs on average
                    // over the classical search.
                    var speedupFactor = Round(empiricalSuccessProbability / classicalSuccessProbability / (double)queries, 3);

                    Console.Write(
                        $"Attempt {idxAttempt}. " +
                        $"Success: {markedQubit},  " +
                        $"Probability: {empiricalSuccessProbability} " +
                        $"Speedup: {speedupFactor} " +
                        $"Found database index {databaseRegister} \n");
                }
            }

            #endregion

        }
    }
}
