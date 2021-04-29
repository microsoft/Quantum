# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

function Build-One {
    param(
        $project,
        [switch]
        $generateQir
    );

    Write-Host "##[info]Building $project..."
    dotnet build $project `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:ASSEMBLY_VERSION `
        /property:QirGeneration=$($generateQir ? "true" : "false")

    if  ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to build $project."
        $script:all_ok = $False
    }

    if ($env:FORCE_CLEANUP -eq "true") {
        # Force cleanup of generated bin and obj folders for this project.
        Write-Host "##[info]Cleaning up bin/obj from $(Split-Path $project -Parent)..."
        Get-ChildItem -Path (Split-Path $project -Parent) -Recurse | Where-Object { ($_.name -eq "bin" -or $_.name -eq "obj") -and $_.attributes -eq "Directory" } | Remove-Item -recurse -force
    }
}

# Get-ChildItem (Join-Path $PSScriptRoot '..') -Recurse -Include '*.sln' `
#     | ForEach-Object { Build-One $_.FullName }

# The commented out lines are projects that are not yet compatible for QIR generation.
$QirProjects = @(
    #(Join-Path $PSScriptRoot .. samples algorithms chsh-game CHSHGame.csproj),
    #(Join-Path $PSScriptRoot .. samples algorithms database-search DatabaseSearchSample.csproj),
    #(Join-Path $PSScriptRoot .. samples algorithms integer-factorization IntegerFactorization.csproj),
    (Join-Path $PSScriptRoot .. samples algorithms oracle-synthesis OracleSynthesis.csproj),
    (Join-Path $PSScriptRoot .. samples algorithms order-finding OrderFinding.csproj),
    (Join-Path $PSScriptRoot .. samples algorithms repeat-until-success RepeatUntilSuccess.csproj),
    (Join-Path $PSScriptRoot .. samples algorithms reversible-logic-synthesis ReversibleLogicSynthesis.csproj),
    (Join-Path $PSScriptRoot .. samples algorithms simple-grover SimpleGroverSample.csproj),
    #(Join-Path $PSScriptRoot .. samples algorithms sudoku-grover SudokuGroverSample.csproj),

    (Join-Path $PSScriptRoot .. samples azure-quantum grover Grover.csproj),
    (Join-Path $PSScriptRoot .. samples azure-quantum hidden-shift HiddenShift.csproj),
    (Join-Path $PSScriptRoot .. samples azure-quantum ising-model IsingModel.csproj),
    (Join-Path $PSScriptRoot .. samples azure-quantum parallel-qrng ParallelQrng.csproj),
    (Join-Path $PSScriptRoot .. samples azure-quantum teleport Teleport.csproj),

    (Join-Path $PSScriptRoot .. samples characterization phase-estimation PhaseEstimationSample.csproj),

    (Join-Path $PSScriptRoot .. samples chemistry AnalyzeHamiltonian 1-AnalyzeHamiltonian.csproj),
    (Join-Path $PSScriptRoot .. samples chemistry CreateHubbardHamiltonian CreateHubbardHamiltonian.csproj),
    #(Join-Path $PSScriptRoot .. samples chemistry GetGateCount 3-GetGateCount.csproj),
    #(Join-Path $PSScriptRoot .. samples chemistry MolecularHydrogen MolecularHydrogen.csproj),
    #(Join-Path $PSScriptRoot .. samples chemistry RunSimulation 2-RunSimulation.csproj),
    #(Join-Path $PSScriptRoot .. samples chemistry SimulateHubbardHamiltonian SimulateHubbardHamiltonian.csproj),

    (Join-Path $PSScriptRoot .. samples error-correction bit-flip-code BitFlipCode.csproj),
    #(Join-Path $PSScriptRoot .. samples error-correction syndrome Syndrome.csproj),

    (Join-Path $PSScriptRoot .. samples getting-started measurement Measurement.csproj),
    (Join-Path $PSScriptRoot .. samples getting-started qrng Qrng.csproj),
    (Join-Path $PSScriptRoot .. samples getting-started simple-algorithms SimpleAlgorithms.csproj),
    (Join-Path $PSScriptRoot .. samples getting-started teleportation TeleportationSample.csproj),

    #(Join-Path $PSScriptRoot .. samples machine-learning half-moons HalfMoons.csproj),
    #(Join-Path $PSScriptRoot .. samples machine-learning parallel-half-moons ParallelHalfMoons.csproj),
    #(Join-Path $PSScriptRoot .. samples machine-learning wine Wine.csproj),

    (Join-Path $PSScriptRoot .. samples numerics CustomModAdd CustomModAdd.csproj),
    (Join-Path $PSScriptRoot .. samples numerics EvaluatingFunctions EvaluatingFunctions.csproj),
    (Join-Path $PSScriptRoot .. samples numerics ResourceCounting ResourceCounting.csproj),

    #(Join-Path $PSScriptRoot .. samples simulation h2 command-line H2SimulationSampleCmdLine.csproj),
    (Join-Path $PSScriptRoot .. samples simulation hubbard HubbardSimulationSample.csproj),
    #(Join-Path $PSScriptRoot .. samples simulation ising adiabatic AdiabaticIsingSample.csproj),
    #(Join-Path $PSScriptRoot .. samples simulation ising generators IsingGeneratorsSample.csproj),
    #(Join-Path $PSScriptRoot .. samples simulation ising phase-estimation IsingPhaseEstimationSample.csproj),
    #(Join-Path $PSScriptRoot .. samples simulation ising simple SimpleIsingSample.csproj),
    #(Join-Path $PSScriptRoot .. samples simulation ising trotter-evolution IsingTrotterSample.csproj),
    (Join-Path $PSScriptRoot .. samples simulation qaoa QAOA.csproj)
)

$qirSln = (Join-Path $PSScriptRoot .. QIR.sln)
dotnet new sln -n QIR -o (Join-Path $PSScriptRoot ..)

$QirProjects `
    | ForEach-Object { 
        dotnet sln $qirSln add $_
        # Build-One $_ -generateQir
    }
Build-One QIR.sln -generateQir
Remove-Item QIR.sln

if (-not $all_ok) {
    throw "At least one test failed execution. Check the logs."
}