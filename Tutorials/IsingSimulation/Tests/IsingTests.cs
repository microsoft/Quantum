using Xunit;


namespace Microsoft.Quantum.TutorialTests
{
    public partial class CircuitSimulator
    {
        [Fact(DisplayName = "Tutorial.StatePreparation")]
        public void StatePreparationTest()
        {
            RunTest(sim =>
            {
                var res = TestStatePreparation.Run(sim).Result;
                output.WriteLine($"State preparation test passed.");
            });
        }

        [Fact(DisplayName = "Tutorial.Xterm")]
        public void XTermTest()
        {
            RunTest(sim =>
            {
                var res = TestXterm.Run(sim).Result;
                output.WriteLine($"X-term test passed.");
            });
        }

        [Fact(DisplayName = "Tutorial.ZZterm")]
        public void ZZTermTest()
        {
            RunTest(sim =>
            {
                var res = TestZZterm.Run(sim).Result;
                output.WriteLine($"ZZ-term test passed.");
            });
        }

        [Fact(DisplayName = "Tutorial.TrotterStep")]
        public void TrotterStepTest()
        {
            RunTest(sim =>
            {
                var res = TestTrotterStep.Run(sim).Result;
                output.WriteLine($"Trotter step test passed.");
            });
        }

        [Fact(DisplayName = "Tutorial.Annealing")]
        public void AnnealingTest()
        {
            RunTest(sim =>
            {
                var res = TestAnnealing.Run(sim).Result;
                output.WriteLine($"Annealing test passed.");
            });
        }

        [Fact(DisplayName = "Tutorial.GroundState")]
        public void GroundStateTest()
        {
            RunTest(sim =>
            {
                var res = TestGroundState.Run(sim).Result;
                output.WriteLine($"Annealing test passed.");
            });
        }
    }
}
