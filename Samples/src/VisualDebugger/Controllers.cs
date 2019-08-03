using System.Collections.Generic;
using System.Numerics;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Quantum.Simulation.Simulators;

namespace vis_sim
{
    [Route("state")]
    [ApiController]
    public class StateController : ControllerBase
    {
        private readonly VisualDebugger debugger;

        public StateController(VisualDebugger debugger)
        {
            this.debugger = debugger;
        }

        [HttpGet]
        public async Task<ActionResult<Complex[]>> GetSimulatorState()
        {
            var dumper = new ApiDumper(debugger.simulator);
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
