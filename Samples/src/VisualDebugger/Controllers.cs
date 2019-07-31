using System.Collections.Generic;
using System.Numerics;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Quantum.Simulation.Simulators;

namespace vis_sim
{
    public class AdvanceEvent
    {
        public ManualResetEvent ReadyToProceed { get; } = new ManualResetEvent(true);
        public void WaitForUser()
        {
            ReadyToProceed.Reset();
            ReadyToProceed.WaitOne();
        }
    }

    [Route("advance")]
    [ApiController]
    public class AdvanceController : ControllerBase
    {
        private readonly AdvanceEvent advance;
        public AdvanceController(AdvanceEvent advance)
        {
            this.advance = advance;
        }

        [HttpGet]
        public async Task<ActionResult<bool>> Advance() =>
            advance.ReadyToProceed.Set();

    }

    [Route("state")]
    [ApiController]
    public class StateController : ControllerBase
    {
        private readonly VisualizationSimulator simulator;

        public StateController(VisualizationSimulator simulator)
        {
            this.simulator = simulator;
        }

        [HttpGet]
        public async Task<ActionResult<Complex[]>> GetSimulatorState()
        {
            var dumper = new ApiDumper(simulator.underlyingSimulator);
            dumper.BeginDump();
            dumper.Dump();
            return dumper.EndDump();
        }

        private class ApiDumper : QuantumSimulator.StateDumper
        {
            private List<Complex> amplitudes = new List<Complex>();
            public ApiDumper(QuantumSimulator qsim) : base(qsim)
            {
            }

            public void BeginDump() => amplitudes = new List<Complex>();
            public Complex[] EndDump() => amplitudes.ToArray();

            public override bool Callback(uint idx, double real, double img)
            {
                amplitudes.Add(new Complex(real, img));
                return true;
            }
        }
    }
}
