using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Samples.Hardware.Syndrome;
using Microsoft.Quantum.Canon;
using System;
using System.Linq;
using Microsoft.Quantum.Diagnostics;

namespace Microsoft.Quantum.Samples.Hardware
{
    public class PseudoSyndromeExperiment
    {
        public class Outcome
        {
            public bool[] inputs;
            public bool[] outputs;
            public Pauli[] bases;
            public long[] interactions;
        }

        public PseudoSyndromeExperiment(uint sample_count, int width, int depth)
        {
            this.sample_count_ = sample_count;
            this.width_ = width;
            this.depth_ = depth;
        }

        public Outcome[] Run(IOperationFactory sim)
        {
            var outcomes = new Outcome[this.sample_count_];
            for (int i = 0; i < this.sample_count_; i++)
            {
                outcomes[i] = Sample(sim);
            }
            return outcomes;
        }

        public Outcome[] Run(IQuantumMachine machine)
        {
            var outcomes = new Outcome[this.sample_count_];
            for (int i = 0; i < this.sample_count_; i++)
            {
                outcomes[i] = Sample(machine);
            }
            return outcomes;
        }

        private Outcome Sample(IOperationFactory sim)
        {
            var indexes = new QArray<long>(MakeRandomIntegerSequence(this.width_, this.depth_));
            var bases = new QArray<Pauli>(MakeRandomPaulis(this.width_));
            var input_values = new QArray<bool>(MakeRandomBoolSequence(this.width_));
            var results = SamplePseudoSyndrome.Run(sim, input_values, bases, indexes).Result;
            return new Outcome
            {
                bases = bases.ToArray(),
                inputs = input_values.ToArray(),
                interactions = indexes.ToArray(),
                outputs = (from result in results 
                           select System.Convert.ToBoolean(result.GetValue())).ToArray()
            };
        }

        private Outcome Sample(IQuantumMachine machine)
        {
            var indexes = new QArray<long>(MakeRandomIntegerSequence(this.width_, this.depth_));
            var bases = new QArray<Pauli>(MakeRandomPaulis(this.width_));
            var input_values = new QArray<bool>(MakeRandomBoolSequence(this.width_));
            var output = machine.Run<SamplePseudoSyndrome,
                (IQArray<bool>, IQArray<Pauli>, IQArray<long>),
                IQArray<Result>>((input_values, bases, indexes), 1).Result;
            var results = output.Result;
            return new Outcome
            {
                bases = bases.ToArray(),
                inputs = input_values.ToArray(),
                interactions = indexes.ToArray(),
                outputs = (from result in results
                           select System.Convert.ToBoolean(result.GetValue())).ToArray()
            };
        }

        private long[] MakeRandomIntegerSequence(int distance, int depth)
        {
            var random = new System.Random();
            var sequence = new long[depth];
            for (int index = 0; index < sequence.Length; index++)
            {
                sequence[index] = random.Next(distance);
            }
            return sequence;
        }

        private bool[] MakeRandomBoolSequence(int length)
        {
            return (from value in MakeRandomIntegerSequence(2, length)
                    select System.Convert.ToBoolean(value)).ToArray();
        }

        private Pauli[] MakeRandomPaulis(int length)
        {
            var paulis = new Pauli[]{ Pauli.PauliX, Pauli.PauliY, Pauli.PauliZ };
            return (from value in MakeRandomIntegerSequence(3, length)
                    select paulis[value]).ToArray();
        }

        private readonly uint sample_count_;
        private readonly int width_;
        private readonly int depth_;
    }
}