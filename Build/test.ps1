# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# NB: Using statements with relative paths are always relative to PSScriptRoot.
using module "./qdk-tools.psm1";

$ErrorActionPreference = 'Stop'
$all_ok = $True

function Test-One {
    Param($project)

    Write-Host "##[info]Testing $project..."
    $commonArgs = Get-CommonDotNetArguments + Get-CommonMSBuildArguments;
    dotnet test (Join-Path $PSScriptRoot $project) `
        --logger trx `
        @commonArgs;

    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to test $project"
        $script:all_ok = $False
    }

    if ($env:FORCE_CLEANUP -eq "true") {
        # Force cleanup of generated bin and obj folders for this project.
        Write-Host "##[info]Cleaning up bin/obj from $(Split-Path (Join-Path $PSScriptRoot $project) -Parent)..."
        Get-ChildItem -Path (Split-Path (Join-Path $PSScriptRoot $project) -Parent) -Recurse | Where-Object { ($_.name -eq "bin" -or $_.name -eq "obj") -and $_.attributes -eq "Directory" } | Remove-Item -recurse -force
    }
}

function Validate-Integrals {
    if (($null -ne $Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))) {
        Push-Location (Join-Path $PSScriptRoot "..\Chemistry\Schema\")
            python validator.py $PSScriptRoot/Samples/chemistry/IntegralData/**/*.yaml broombridge-0.1.schema.json

            if  ($LastExitCode -ne 0) {
                Write-Host "##vso[task.logissue type=error;]Failed to validate IntegralData"
                $script:all_ok = $False
            }
        Pop-Location
    } else {
        Write-Host "##vso[task.logissue type=warning;]Validation of IntegralData only supported in Windows."
    }
}


# The AutoSubstitution sample uses the Microsoft.Quantum.AutoSubstitution NuGet
# package that implements a Q# rewrite step.  If the package works as expected,
# the program outputs two different strings depending on which simulator
# (QuantumSimulator or ToffoliSimulator) is used.
function Test-AutoSubstitution {
    Write-Host "##[info]Testing AutoSubstitution sample..."

    $output = dotnet run --project (Join-Path $PSScriptRoot "../samples/runtime/autosubstitution")

    if ($output -notmatch "^Quantum version\s*$") {
        Write-Host "##vso[task.logissue type=error;]Auto substitution with QuantumSimulator failed, the wrong operation was called, expected 'Quantum version'"
        $script:all_ok = $False
    } else {
        $output = dotnet run --project (Join-Path $PSScriptRoot "../samples/runtime/autosubstitution") -s ToffoliSimulator

        if ($output -notmatch "^Classical version\s*$") {
            Write-Host "##vso[task.logissue type=error;]Auto substitution with ToffoliSimulator failed, the wrong operation was called, expected 'Classical version'"
            $script:all_ok = $False
        }
    }
}

Validate-Integrals

# Disabled for now, as it breaks in e2e builds
# Test-AutoSubstitution

Test-One '../samples/tests/sample-tests'
Test-One '../samples/diagnostics/unit-testing'

# Next, we'll try to make sure that all C# + Q# and Q# command-line samples actually run
# with the dotnet command. To do so, we'll recurse through all csproj files, excluding those
# projects we know that cannot be tested in this way (e.g.: require GUI support, or
# are library projects included from other projects).

# Some projects require additional arguments at the command line, which we
# collect here. Note that we allow for each project to specify multiple lists
# of arguments, so that we can test samples in different configurations
# and against different simulators.
$projectArgs = @{
        "../samples/algorithms/database-search/DatabaseSearchSample.csproj" = @(,
            @("simulate", "Microsoft.Quantum.Samples.DatabaseSearch.RunRandomSearch"),
            @("simulate", "Microsoft.Quantum.Samples.DatabaseSearch.RunQuantumSearch"),
            @("simulate", "Microsoft.Quantum.Samples.DatabaseSearch.RunMultipleQuantumSearch")
        );

        "../samples/simulation/qaoa/QAOA.csproj" = @(,
            @("--num-trials", "10")
        );

        "../samples/algorithms/order-finding/OrderFinding.csproj" = @(,
            @("--index", "3")
        );

        "../samples/algorithms/repeat-until-success/RepeatUntilSuccess.csproj" = @(,
            @("--gate", "simple", "--input-value", "true", "--input-basis", "PauliX", "--limit", "3", "--num-runs", "2"),
            @("--gate", "V", "--input-value", "true", "--input-basis", "PauliZ", "--limit", "3", "--num-runs", "2")
        );

        "../samples/algorithms/simple-grover/SimpleGroverSample.csproj" = @(,
            @("--n-qubits", "3")
        );

        "../samples/azure-quantum/grover/Grover.csproj" = @(,
            @("simulate", "--n-qubits", "3", "--idx-marked", "6")
        );

        "../samples/azure-quantum/ising-model/IsingModel.csproj" = @(,
            @("simulate", "--n-sites", "3", "--time", "10", "--dt", "0.1")
        );

        "../samples/azure-quantum/teleport/Teleport.csproj" = @(,
            @("simulate", "--prep-basis", "PauliX", "--meas-basis", "PauliZ")
        );

        "../samples/azure-quantum/hidden-shift/HiddenShift.csproj" = @(,
            @("simulate", "--pattern-int", "6", "--register-size", "3")
        );

        "../samples/azure-quantum/parallel-qrng/ParallelQrng.csproj" = @(,
            @("simulate")
        );

        "../samples/error-correction/syndrome/Syndrome.csproj" = @(,
            @("--n-qubits", "5")
        );

        "../samples/simulation/gaussian-initial-state/gaussian-initial-state.csproj" = @(,
            @("--recursive", "false", "--n-qubits", "5"),
            @("--recursive", "true", "--n-qubits", "5")
        );

        "../samples/simulation/ising/IsingSamples.csproj" = @(,
            @("simulate", "Microsoft.Quantum.Samples.Ising.RunSimple"),
            @("simulate", "Microsoft.Quantum.Samples.Ising.RunGenerators"),
            @("simulate", "Microsoft.Quantum.Samples.Ising.RunAdiabaticEvolution"),
            @("simulate", "Microsoft.Quantum.Samples.Ising.RunPhaseEstimation"),
            @("simulate", "Microsoft.Quantum.Samples.Ising.RunTrotterSuzuki")
        );

        "../samples/runtime/reversible-simulator-advanced/host/host.csproj" = @(,
            @("-a", "true", "-b", "true", "-c", "false")
        );

        "../samples/getting-started/simple-algorithms/SimpleAlgorithms.csproj" = @(,
            @("--n-qubits", "4") # NB: Must be an even number of qubits.
        );
    }.GetEnumerator() `
    | ForEach-Object {
        @{
            "Key" = (Resolve-Path (Join-Path $PSScriptRoot $_.Key)).Path;
            "Value" = $_.Value
        }
    } `
    | Convert-ObjectsToHashtable;

# IMPORTANT: Do not add projects to the blocklist without an explanation as to why,
#            and a path towards removing those projects from the blocklist in the future.
$runBlockList = @(
    # The following samples are too slow to include at the moment.
    # We can allow this projects by improving performance, or by allowing longer
    # build times.
    "../samples/algorithms/sudoku-grover/SudokuGroverSample.csproj",
    "../samples/machine-learning/wine/Wine.csproj",

    # The following samples are not really standalone, but can be made standalone
    # by improving how file paths are handled.
    "../samples/chemistry/AnalyzeHamiltonian/1-AnalyzeHamiltonian.csproj",
    "../samples/chemistry/RunSimulation/2-RunSimulation.csproj",
    "../samples/chemistry/GetGateCount/3-GetGateCount.csproj",

    # The following samples are GUI samples, and would require a GUI testing
    # framework to run here.
    "../samples/chemistry/MolecularHydrogenGUI/MolecularHydrogenGUI.csproj",
    "../samples/chemistry/LithiumHydrideGUI/LithiumHydrideGUI.csproj",
    "../samples/simulation/h2/gui/H2SimulationGUI.csproj",

    # The following project can only be executed by submitting it to Azure Quantum
    # Resource Estimator and therefore cannot be build
    "../samples/azure-quantum/resource-estimation/integer-factorization-with-cli/integer-factorization.csproj"
) | ForEach-Object { (Resolve-Path (Join-Path $PSScriptRoot $_)).Path };

$projectsToRun = Get-ChildItem -Recurse -Path (Join-Path $PSScriptRoot ".." "*.csproj") `
    | Where-Object { (Get-ProjectKind $_.FullName) -eq [ProjectKind]::Executable } `
    | Where-Object { $_.FullName -notin $runBlockList };
$nFailed = 0;

Measure-Command {
    $projectsToRun `
        | ForEach-Object {
            $additionalArgs = $projectArgs.ContainsKey($_.FullName) ? $projectArgs[$_.FullName] : @(,@());
            foreach ($trialArgs in $additionalArgs) {
                Write-Host "##[info] Running sample at $_ with arguments '$trialArgs'...";
                Invoke-Project $_ -AdditionalArgs $trialArgs | Out-Default;
                if ($LastExitCode -ne 0) {
                    Write-Host "##[error] Failed running project $_.";
                    $script:all_ok = $False;
                    $nFailed += 1;
                }
            }
        }

    Write-Host "Ran $($projectsToRun.Length) samples, skipped $($runBlockList.Length), $nFailed failed.";
}

if (-not $all_ok) {
    throw "At least one project failed to compile. Check the logs."
}

