# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$allOk = $True

function Build-One {
    param(
        $Project,
        $Arguments
    );

    $projectDirectory = $(Split-Path $Project -Parent)
    $projectName = $(Split-Path $Project -LeafBase)

    Push-Location $projectDirectory

    Write-Host "##[info]Building $Project..."
    dotnet build $Project `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        --no-dependencies `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:ASSEMBLY_VERSION `
        /property:QirGeneration="true"

    if  ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to build $Project."
        $script:allOk = $False
    } else {
        qir-cli `
            --dll (Join-Path bin $Env:BUILD_CONFIGURATION netcoreapp3.1 "${projectName}.dll") `
            --exe qir
        if  ($LastExitCode -ne 0) {
            Write-Host "##vso[task.logissue type=error;]Failed to build $Project."
            $script:allOk = $False
        } else {
            Get-ChildItem (Join-Path qir *__Interop.exe) `
                | ForEach-Object { & $_ @Arguments}
            if  ($LastExitCode -ne 0) {
                Write-Host "##vso[task.logissue type=error;]$Project encountered an error or failed during execution."
                $script:allOk = $False
            }
        }
    }

    if ($env:FORCE_CLEANUP -eq "true") {
        # Force cleanup of generated bin, obj, and qir folders for this project.
        Write-Host "##[info]Cleaning up bin/obj from $projectDirectory..."
        Get-ChildItem -Path $projectDirectory -Recurse | Where-Object { ($_.name -eq "bin" -or $_.name -eq "obj" -or $_.name -eq "qir") -and $_.attributes -eq "Directory" } | Remove-Item -recurse -force
    }

    Pop-Location
}

# The commented out lines are sample projects that are not yet compatible for QIR generation/execution. 
# 'not compatible' means that the structure of the sample is not compatible for QIR generation.
# 'needs argument(s)' means that the sample can generated QIR, but running the exe requires command line arguments.
$qirProjects = @(
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples algorithms chsh-game CHSHGame.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples algorithms database-search DatabaseSearchSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples algorithms integer-factorization IntegerFactorization.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples algorithms oracle-synthesis OracleSynthesis.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples algorithms order-finding OrderFinding.csproj); Args = @("--index", "1") },
    @{ Path = (Join-Path $PSScriptRoot .. samples algorithms repeat-until-success RepeatUntilSuccess.csproj); Args = @("--gate", "simple", "--input-value", "true", "--input-basis", "PauliX", "--limit", "4", "--num-runs", "2") },
    @{ Path = (Join-Path $PSScriptRoot .. samples algorithms reversible-logic-synthesis ReversibleLogicSynthesis.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples algorithms simple-grover SimpleGroverSample.csproj); Args = @("--nQubits", "8") },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples algorithms sudoku-grover SudokuGroverSample.csproj); Args = @() },

    # needs argument(s) #@{ Path = (Join-Path $PSScriptRoot .. samples azure-quantum grover Grover.csproj); Args = @() },
    # needs argument(s) #@{ Path = (Join-Path $PSScriptRoot .. samples azure-quantum hidden-shift HiddenShift.csproj); Args = @() },
    # needs argument(s) #@{ Path = (Join-Path $PSScriptRoot .. samples azure-quantum ising-model IsingModel.csproj); Args = @() },
    # needs argument(s) #@{ Path = (Join-Path $PSScriptRoot .. samples azure-quantum parallel-qrng ParallelQrng.csproj); Args = @() },
    # needs argument(s) #@{ Path = (Join-Path $PSScriptRoot .. samples azure-quantum teleport Teleport.csproj); Args = @() },

    @{ Path = (Join-Path $PSScriptRoot .. samples characterization phase-estimation PhaseEstimationSample.csproj); Args = @() },

    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples chemistry AnalyzeHamiltonian 1-AnalyzeHamiltonian.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples chemistry CreateHubbardHamiltonian CreateHubbardHamiltonian.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples chemistry GetGateCount 3-GetGateCount.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples chemistry MolecularHydrogen MolecularHydrogen.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples chemistry RunSimulation 2-RunSimulation.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples chemistry SimulateHubbardHamiltonian SimulateHubbardHamiltonian.csproj); Args = @() },

    @{ Path = (Join-Path $PSScriptRoot .. samples error-correction bit-flip-code BitFlipCode.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples error-correction syndrome Syndrome.csproj); Args = @() },

    @{ Path = (Join-Path $PSScriptRoot .. samples getting-started measurement Measurement.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples getting-started qrng Qrng.csproj); Args = @() },
    # needs argument(s) #@{ Path = (Join-Path $PSScriptRoot .. samples getting-started simple-algorithms SimpleAlgorithms.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples getting-started teleportation TeleportationSample.csproj); Args = @() }

    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples machine-learning half-moons HalfMoons.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples machine-learning parallel-half-moons ParallelHalfMoons.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples machine-learning wine Wine.csproj); Args = @() },

    @{ Path = (Join-Path $PSScriptRoot .. samples numerics CustomModAdd CustomModAdd.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples numerics EvaluatingFunctions EvaluatingFunctions.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples numerics ResourceCounting ResourceCounting.csproj); Args = @() },

    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation h2 command-line H2SimulationSampleCmdLine.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples simulation hubbard HubbardSimulationSample.csproj); Args = @() }
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation ising adiabatic AdiabaticIsingSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation ising generators IsingGeneratorsSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation ising phase-estimation IsingPhaseEstimationSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation ising simple SimpleIsingSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation ising trotter-evolution IsingTrotterSample.csproj); Args = @() },
    # needs argument(s) #@{ Path = (Join-Path $PSScriptRoot .. samples simulation qaoa QAOA.csproj); Args = @() }
)

if (-not (Get-Command qir-cli -ErrorAction SilentlyContinue)) {
    dotnet tool install Microsoft.Quantum.Qir.CommandLineTool -g
}

if (-not (Get-Command qir-cli -ErrorAction SilentlyContinue)) {
    Write-Host "##[error]The qir-cli command is missing; you can install it by running `dotnet tool install Microsoft.Quantum.Qir.CommandLineTool -g`.";
    $script:allOk = $False
} else {
    $qirProjects `
        | ForEach-Object { Build-One $_.Path $_.Args }
}

if (-not $allOk) {
    throw "At least one sample failed build. Check the logs."
}