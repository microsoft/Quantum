# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

function Build-One {
    param(
        $project
    );

    $project_directory = $(Split-Path $project -Parent)
    $project_name = $(Split-Path $project -LeafBase)

    pushd $project_directory

    Write-Host "##[info]Building $project..."
    dotnet build $project `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        --no-dependencies `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:ASSEMBLY_VERSION `
        /property:QirGeneration="true"

    if  ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to build $project."
        $script:all_ok = $False
    } else {
        qir-cli `
            --dll (Join-Path bin $Env:BUILD_CONFIGURATION netcoreapp3.1 "${project_name}.dll") `
            --exe qir
        if  ($LastExitCode -ne 0) {
            Write-Host "##vso[task.logissue type=error;]Failed to build $project."
            $script:all_ok = $False
        } else {
            Get-ChildItem (Join-Path qir *__Interop.exe) `
                | ForEach-Object { & $_ }
            if  ($LastExitCode -ne 0) {
                Write-Host "##vso[task.logissue type=error;]$project encountered an error or failed during execution."
                $script:all_ok = $False
            }
        }
    }

    if ($env:FORCE_CLEANUP -eq "true") {
        # Force cleanup of generated bin, obj, and qir folders for this project.
        Write-Host "##[info]Cleaning up bin/obj from $project_directory..."
        Get-ChildItem -Path $project_directory -Recurse | Where-Object { ($_.name -eq "bin" -or $_.name -eq "obj" -or $_.name -eq "qir") -and $_.attributes -eq "Directory" } | Remove-Item -recurse -force
    }

    popd
}

# The commented out lines are sample projects that are not yet compatible for QIR generation/execution. 
# 'not compatible' means that the structure of the sample is not compatible for QIR generation.
# 'needs argument(s)' means that the sample can generated QIR, but running the exe requires command line arguments.
# 'package version issue' means there is an issue with the versioning of the packages involved, disallowing QIR generation.
$QirProjects = @(
    # not compatible #(Join-Path $PSScriptRoot .. samples algorithms chsh-game CHSHGame.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples algorithms database-search DatabaseSearchSample.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples algorithms integer-factorization IntegerFactorization.csproj),
    (Join-Path $PSScriptRoot .. samples algorithms oracle-synthesis OracleSynthesis.csproj),
    # needs argument(s) #(Join-Path $PSScriptRoot .. samples algorithms order-finding OrderFinding.csproj),
    # needs argument(s) #(Join-Path $PSScriptRoot .. samples algorithms repeat-until-success RepeatUntilSuccess.csproj),
    (Join-Path $PSScriptRoot .. samples algorithms reversible-logic-synthesis ReversibleLogicSynthesis.csproj),
    # needs argument(s) #(Join-Path $PSScriptRoot .. samples algorithms simple-grover SimpleGroverSample.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples algorithms sudoku-grover SudokuGroverSample.csproj),

    # needs argument(s) #(Join-Path $PSScriptRoot .. samples azure-quantum grover Grover.csproj),
    # needs argument(s) #(Join-Path $PSScriptRoot .. samples azure-quantum hidden-shift HiddenShift.csproj),
    # needs argument(s) #(Join-Path $PSScriptRoot .. samples azure-quantum ising-model IsingModel.csproj),
    # needs argument(s) #(Join-Path $PSScriptRoot .. samples azure-quantum parallel-qrng ParallelQrng.csproj),
    # package version issue #(Join-Path $PSScriptRoot .. samples azure-quantum teleport Teleport.csproj),

    (Join-Path $PSScriptRoot .. samples characterization phase-estimation PhaseEstimationSample.csproj),

    # not compatible #(Join-Path $PSScriptRoot .. samples chemistry AnalyzeHamiltonian 1-AnalyzeHamiltonian.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples chemistry CreateHubbardHamiltonian CreateHubbardHamiltonian.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples chemistry GetGateCount 3-GetGateCount.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples chemistry MolecularHydrogen MolecularHydrogen.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples chemistry RunSimulation 2-RunSimulation.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples chemistry SimulateHubbardHamiltonian SimulateHubbardHamiltonian.csproj),

    (Join-Path $PSScriptRoot .. samples error-correction bit-flip-code BitFlipCode.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples error-correction syndrome Syndrome.csproj),

    (Join-Path $PSScriptRoot .. samples getting-started measurement Measurement.csproj),
    (Join-Path $PSScriptRoot .. samples getting-started qrng Qrng.csproj),
    # needs argument(s) #(Join-Path $PSScriptRoot .. samples getting-started simple-algorithms SimpleAlgorithms.csproj),
    (Join-Path $PSScriptRoot .. samples getting-started teleportation TeleportationSample.csproj),

    # not compatible #(Join-Path $PSScriptRoot .. samples machine-learning half-moons HalfMoons.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples machine-learning parallel-half-moons ParallelHalfMoons.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples machine-learning wine Wine.csproj),

    # package version issue #(Join-Path $PSScriptRoot .. samples numerics CustomModAdd CustomModAdd.csproj),
    # package version issue #(Join-Path $PSScriptRoot .. samples numerics EvaluatingFunctions EvaluatingFunctions.csproj),
    # package version issue #(Join-Path $PSScriptRoot .. samples numerics ResourceCounting ResourceCounting.csproj),

    # not compatible #(Join-Path $PSScriptRoot .. samples simulation h2 command-line H2SimulationSampleCmdLine.csproj),
    (Join-Path $PSScriptRoot .. samples simulation hubbard HubbardSimulationSample.csproj)
    # not compatible #(Join-Path $PSScriptRoot .. samples simulation ising adiabatic AdiabaticIsingSample.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples simulation ising generators IsingGeneratorsSample.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples simulation ising phase-estimation IsingPhaseEstimationSample.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples simulation ising simple SimpleIsingSample.csproj),
    # not compatible #(Join-Path $PSScriptRoot .. samples simulation ising trotter-evolution IsingTrotterSample.csproj),
    # needs argument(s) #(Join-Path $PSScriptRoot .. samples simulation qaoa QAOA.csproj)
)

$QirProjects `
    | ForEach-Object { Build-One $_ }

if (-not $all_ok) {
    throw "At least one sample failed build. Check the logs."
}