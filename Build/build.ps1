# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

function Build-One {
    param(
        $project,
        $qirGenerationFlag
    );

    Write-Host "##[info]Building $project..."
    dotnet build $project `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:ASSEMBLY_VERSION `
        /property:QirGeneration=$qirGenerationFlag

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

Get-ChildItem (Join-Path $PSScriptRoot '..') -Recurse -Include '*.sln' `
    | ForEach-Object { Build-One $_.FullName $False }

$QirProjects = @(
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'algorithms', 'chsh-game', 'CHSHGame.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'algorithms', 'database-search', 'DatabaseSearchSample.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'algorithms', 'integer-factorization', 'IntegerFactorization.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'algorithms', 'oracle-synthesis', 'OracleSynthesis.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'algorithms', 'order-finding', 'OrderFinding.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'algorithms', 'repeat-until-success', 'RepeatUntilSuccess.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'algorithms', 'reversible-logic-synthesis', 'ReversibleLogicSynthesis.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'algorithms', 'simple-grover', 'SimpleGroverSample.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'algorithms', 'sudoku-grover', 'SudokuGroverSample.csproj'),

    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'azure-quantum', 'grover', 'Grover.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'azure-quantum', 'hidden-shift', 'HiddenShift.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'azure-quantum', 'ising-model', 'IsingModel.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'azure-quantum', 'parallel-qrng', 'ParallelQrng.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'azure-quantum', 'teleport', 'Teleport.csproj'),

    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'characterization', 'phase-estimation', 'PhaseEstimationSample.csproj'),

    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'chemistry', 'AnalyzeHamiltonian', '1-AnalyzeHamiltonian.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'chemistry', 'CreateHubbardHamiltonian', 'CreateHubbardHamiltonian.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'chemistry', 'GetGateCount', '3-GetGateCount.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'chemistry', 'MolecularHydrogen', 'MolecularHydrogen.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'chemistry', 'RunSimulation', '2-RunSimulation.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'chemistry', 'SimulateHubbardHamiltonian', 'SimulateHubbardHamiltonian.csproj'),

    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'error-correction', 'bit-flip-code', 'BitFlipCode.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'error-correction', 'syndrome', 'Syndrome.csproj'),

    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'getting-started', 'measurement', 'Measurement.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'getting-started', 'qrng', 'Qrng.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'getting-started', 'simple-algorithms', 'SimpleAlgorithms.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'getting-started', 'teleportation', 'TeleportationSample.csproj'),

    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'machine-learning', 'half-moons', 'HalfMoons.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'machine-learning', 'parallel-half-moons', 'ParallelHalfMoons.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'machine-learning', 'wine', 'Wine.csproj'),

    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'numerics', 'CustomModAdd', 'CustomModAdd.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'numerics', 'EvaluatingFunctions', 'EvaluatingFunctions.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'numerics', 'ResourceCounting', 'ResourceCounting.csproj'),

    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'simulation', 'h2', 'command-line', 'H2SimulationSampleCmdLine.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'simulation', 'hubbard', 'HubbardSimulationSample.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'simulation', 'ising', 'adiabatic', 'AdiabaticIsingSample.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'simulation', 'ising', 'generators', 'IsingGeneratorsSample.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'simulation', 'ising', 'phase-estimation', 'IsingPhaseEstimationSample.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'simulation', 'ising', 'simple', 'SimpleIsingSample.csproj'),
    #[IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'simulation', 'ising', 'trotter-evolution', 'IsingTrotterSample.csproj'),
    [IO.Path]::Combine($PSScriptRoot, '..', 'samples', 'simulation', 'qaoa', 'QAOA.csproj')
)

$QirProjects `
    | ForEach-Object { Build-One $_ $True }

if (-not $all_ok) {
    throw "At least one test failed execution. Check the logs."
}