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

# Validate-Integrals

# Test-One '../samples/tests/sample-tests'
# Test-One '../samples/diagnostics/unit-testing'

# Next, we'll try to make sure that all C# + Q# and Q# command-line samples actually run
# with the dotnet command. To do so, we'll recurse through all csproj files, excluding those
# projects we know that cannot be tested in this way (e.g.: require GUI support, or
# are library projects included from other projects).
# IMPORTANT: Do not add projects to the blocklist without an explanation as to why,
#            and a path towards removing those projects from the blocklist in the future.
$runBlockList = @(
    # The following projects require command-line arguments to run.
    # See https://github.com/microsoft/qsharp-compiler/issues/1013 for discussion.
    "../samples/algorithms/order-finding/OrderFinding.csproj",
    "../samples/algorithms/repeat-until-success/RepeatUntilSuccess.csproj",
    "../samples/algorithms/simple-grover/SimpleGroverSample.csproj",
    "../samples/azure-quantum/grover/Grover.csproj",
    "../samples/azure-quantum/ising-model/IsingModel.csproj",
    "../samples/azure-quantum/teleport/Teleport.csproj",
    "../samples/azure-quantum/hidden-shift/HiddenShift.csproj",
    "../samples/azure-quantum/parallel-qrng/ParallelQrng.csproj",

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
    "../samples/chemistry/LithiumHydrideGUI/LithiumHydrideGUI.csproj"
) | ForEach-Object { (Resolve-Path (Join-Path $PSScriptRoot $_)).Path };

$projectsToRun = Get-ChildItem -Recurse -Path (Join-Path ".." "*.csproj") `
    | Where-Object { (Get-ProjectKind $_.FullName) -eq [ProjectKind]::Executable } `
    | Where-Object { $_.FullName -notin $runBlockList };
$nFailed = 0;
$projectsToRun `
    | ForEach-Object {
        Write-Host "##[info] Running sample at $_...";
        Measure-Command { Invoke-Project $_ };
        if ($LastExitCode -ne 0) {
            Write-Host "##[error] Failed running project $_.";
            $script:all_ok = $False;
            $nFailed += 1;
        }
    }

Write-Host "Ran $($projectsToRun.Length) samples, skipped $($runBlockList.Length), $nFailed failed.";

if (-not $all_ok) {
    throw "At least one project failed to compile. Check the logs."
}

