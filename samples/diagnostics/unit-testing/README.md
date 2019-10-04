# Unit Testing Sample #

This sample set illustrates techniques for testing the correctness of the circuits and
computing metrics describing circuits such as number of qubits used, gate counts and
depth. We implement, test and compute metrics for the circuits from the following categories

* [CCNOT, also know as Toffoli gates](./MultiControlledNOT.qs)
* [Controlled-SWAP, also known as Fredkin gates](./ControlledSWAP.qs)
* [Multi-target CNOT gates](./MultiTargetCNOT.qs)
* [Teleportation circuits](./Teleportation.qs)
* [Repeat Until Success Circuits](./RepeatUntilSuccessCircuits.qs)
* [Multiply controlled Not gates](./MultiControlledNOT.qs)
* [Super-dense coding](./SuperdenseCoding.qs)

Each file illustrating the category is accompanied with the file ending "Tests" with test for
the circuits. The list of the test files is below:

* [Tests for CCNOT, also known as Toffoli gates](./MultiControlledNOTTests.qs)
* [Tests for Controlled-SWAP, also known as Fredkin gates](./ControlledSWAPTests.qs)
* [Tests for Multi-target CNOT gates](./MultiTargetCNOTTests.qs)
* [Tests for Teleportation circuits](./TeleportationTests.qs)
* [Tests for Repeat Until Success Circuits](./RepeatUntilSuccessCircuitsTests.qs)
* [Tests for Multiply controlled Not gates](./MultiControlledNOTTests.qs)
* [Tests for Super-dense coding](./SuperdenseCodingTests.qs)

## Functions from Microsoft.Quantum.Canon used for testing ##

The correctness of all the circuits in this sample is tested using the following
function from Microsoft.Quantum.Canon:

* AssertOperationsEqualReferenced
* AssertOperationsEqualInPlace
* AssertQubitState

## Test harness ##

This sample uses Microsoft.Quantum.Xunit extension to [xUnit.net](http://xunit.github.io/) framework to
automatically discover Q# tests. The tests are all the operations with signature "() => ()"
with suffix "Test". The test harness located in
[QuantumSimulatorTestTargets.cs](./QuantumSimulatorTestTargets.cs).

## Metrics calculation ##

In addition to testing the correctness of the circuit we also compute their metrics such as
gate counts, depth and number of qubit used. Metrics calculation is illustrated in files
ending "Metrics":

* [Metrics for CCNOT, also known as Toffoli gates](./CCNOTCircuitsMetrics.cs)
* [Metrics for Controlled-SWAP, also known as Fredkin gates](./ControlledSWAPMetrics.cs)
* [Metrics for Repeat Until Success Circuits](./RepeatUntilSuccessCircuitsMetrics.cs)
* [Metrics for Multiply controlled Not gates](./MultiControlledNOTMetrics.cs)

File [MetricCalculationUtils.cs](./MetricCalculationUtils.cs) contains the function that creates
QCTraceSimulator configured for metric calculation.

## Sample dependencies ##

This samples uses Microsoft.Quantum.Canon library and depends on the following NuGet packages:

* Microsoft.Quantum.Development.Kit: Q# runtime framework
* Microsoft.Quantum.Xunit: xUnit.net extension for discovering Q# tests
* [xunit](http://xunit.github.io/): xUnit.net testing framework for .NET
