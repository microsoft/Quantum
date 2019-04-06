// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.Simulation.Emulation
{
    /// <summary>
    /// 
    /// </summary>
    public class PermutationOracle
    {
        [DllImport(QuantumSimulator.QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "sim_PermuteBasis")]
        private static extern void PermuteBasisTable(uint id, uint num_qbits, [In] uint[] qbits, long table_size, [In] long[] permutation_table);
        [DllImport(QuantumSimulator.QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "sim_AdjPermuteBasis")]
        private static extern void AdjPermuteBasisTable(uint id, uint num_qbits, [In] uint[] qbits, long table_size, [In] long[] permutation_table);

        private static Int64[] BuildPermutationTable(Func<Int64, Int64, Int64> oracle, int nx, int ny)
        {
            Int64 xmask = (1L << nx) - 1L;
            Int64 ymask = ((1L << ny) - 1L) << nx;
            Int64 table_size = 1L << (nx + ny);

            var permutation = new Int64[table_size];
            for (Int64 state = 0; state < table_size; ++state)
            {
                Int64 x = state & xmask;
                Int64 y = (state & ymask) >> nx;
                Int64 z = oracle(x, y);
                Int64 result = x | (z << nx);
                permutation[state] = result;
            }

            return permutation;
        }

        // Check whether the given permutation table is actually bijective.
        public static bool CheckPermutation(Int64[] permutation)
        {
            var mapped = new BitArray(permutation.Length);
            for (int i = 0; i < permutation.Length; ++i)
            {
                var j = (int)permutation[i];
                Debug.Assert(j >= 0 && j < permutation.Length);
                mapped[j] = true;
            }
            for (int i = 0; i < permutation.Length; ++i)
            {
                if (!mapped[i])
                    return false;
            }
            return true;
        }

        // The main entry point for emulation of a permutation oracle: Apply the permutation
        // defined by the oracle function f: (x, y) -> (x, f(x, y)).
        //
        // TODO: Generalize to arbitrary number of register arguments, i.e. have the oracle
        //  function map a tuple of input values to a tuple of output values?
        public static void ApplyOracle(QuantumSimulator simulator, Func<Int64, Int64, Int64> oracle,
             QArray<Qubit> xbits, QArray<Qubit> ybits, bool adjoint = false)
        {
            var permutation = BuildPermutationTable(oracle, (int)xbits.Length, (int)ybits.Length);
            ApplyOracle(simulator, permutation, xbits, ybits, adjoint);
        }

        // Apply a permutation defined by a permutation table.
        // (Allows for perfomance optimizations like reusing perm tables or creating the tables in C++.)
        public static void ApplyOracle(QuantumSimulator simulator, Int64[] permutation,
             QArray<Qubit> xbits, QArray<Qubit> ybits, bool adjoint = false)
        {
            simulator.CheckQubits(xbits, "x");
            simulator.CheckQubits(ybits, "y");
            Debug.Assert(CheckPermutation(permutation));
            var qbits = (xbits + ybits).GetIds();
            if (adjoint)
                AdjPermuteBasisTable(simulator.Id, (uint)qbits.Length, qbits, permutation.LongLength, permutation);
            else
                PermuteBasisTable(simulator.Id, (uint)qbits.Length, qbits, permutation.LongLength, permutation);
        }

        // Infrastructure to allow for programmatic definition and registration of new oracles.
        private class PermutationOracleImpl<Op> : Adjointable<(QArray<Qubit>, QArray<Qubit>)>, ICallable
        {
            private static Dictionary<Type, Func<Int64, Int64, Int64>> registered_permutations = new Dictionary<Type, Func<Int64, Int64, Int64>>();
            public static void RegisterPermutation(Func<Int64, Int64, Int64> permutation)
            {
                registered_permutations[typeof(Op)] = permutation;
            }

            private QuantumSimulator Simulator { get; }
            private Func<Int64, Int64, Int64> Permutation { get; }

            public PermutationOracleImpl(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
                this.Permutation = registered_permutations[typeof(Op)]; ;
            }

            public PermutationOracleImpl(QuantumSimulator m, Func<Int64, Int64, Int64> permutation) : base(m)
            {
                this.Simulator = m;
                this.Permutation = permutation;
            }

            string ICallable.FullName => $"PermutationOracleImpl<{typeof(Op)}>";

            public override void Init() { }

            public override Func<(QArray<Qubit>, QArray<Qubit>), QVoid> Body => (_args) =>
            {
                var (xbits, ybits) = _args;
                ApplyOracle(this.Simulator, this.Permutation, xbits, ybits, adjoint: false);
                return QVoid.Instance;
            };

            public override Func<(QArray<Qubit>, QArray<Qubit>), QVoid> AdjointBody => (_args) =>
            {
                var (xbits, ybits) = _args;
                ApplyOracle(this.Simulator, this.Permutation, xbits, ybits, adjoint: true);
                return QVoid.Instance;
            };
        }

        /// <summary>
        /// Create an oracle Operation that applies a permutation to the basis states of two registers.
        /// </summary>
        /// <param name="simulator"></param>
        /// <param name="permutation"></param>
        /// <returns></returns>
        public static Adjointable<(QArray<Qubit>, QArray<Qubit>)> Create(QuantumSimulator simulator, Func<Int64, Int64, Int64> permutation)
        {
            return new PermutationOracleImpl<ICallable>(simulator, permutation);
        }

        /// <summary>
        /// Register a permutation oracle as the implementation of the operation "Op", which is typically a Q# declaration of the form
        ///     operation MyOracle(xbits : Qubit[], ybits : Qubit[]) : Unit
        ///     {
        ///         body intrinsic;
        ///         adjoint intrinsic;
        ///     }
        /// </summary>
        /// <typeparam name="Op"></typeparam>
        /// <param name="simulator"></param>
        /// <param name="permutation"></param>
        public static void Register<Op>(QuantumSimulator simulator, Func<Int64, Int64, Int64> permutation)
        {
            PermutationOracleImpl<Op>.RegisterPermutation(permutation);
            simulator.Register(typeof(Op), typeof(PermutationOracleImpl<Op>), typeof(ICallable));

        }
    }


    /// <summary>
    /// QuantumEmulator is a QuantumSimulator exposing an additional EmulateOracle primitive.
    /// </summary>
    public class QuantumEmulator : QuantumSimulator
    {
        /// <summary>
        /// Emulate the effect of a classical oracle by permuting the basis states of the simulator's wavefunction
        /// such that |x>|y>|w> -> |x>|f(x, y)>|w>, with registers x, y, w and the oracle function f.
        /// The oracle
        ///     f: (x, y) -> (x, z=f(x, y)) 
        /// is passed as the first argument to EmulateOracle and must be a bijective mapping on the computational basis states.
        /// </summary>
        public class QSimEmulateOracle : Quantum.Extensions.Emulation.EmulateOracle
        {
            private QuantumSimulator Simulator { get; }

            public QSimEmulateOracle(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(ICallable, QArray<Qubit>, QArray<Qubit>), QVoid> Body => (_args) =>
            {
                var (oracle, xbits, ybits) = _args;
                PermutationOracle.ApplyOracle(this.Simulator, (x, y) => oracle.Apply<Int64>((x, y)), xbits, ybits, adjoint: false);
                return QVoid.Instance;
            };

            public override Func<(ICallable, QArray<Qubit>, QArray<Qubit>), QVoid> AdjointBody => (_args) =>
            {
                var (oracle, xbits, ybits) = _args;
                PermutationOracle.ApplyOracle(this.Simulator, (x, y) => oracle.Apply<Int64>((x, y)), xbits, ybits, adjoint: true);
                return QVoid.Instance;
            };
        }

    }
}
