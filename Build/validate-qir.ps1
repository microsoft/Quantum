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
        Write-Host "##[info]Compiling $projectName to executable..."
        qir-cli `
            --dll (Join-Path bin $Env:BUILD_CONFIGURATION netcoreapp3.1 "${projectName}.dll") `
            --exe qir
        if  ($LastExitCode -ne 0 -or (Get-ChildItem (Join-Path qir *__Interop.exe)).count -eq 0) {
            Write-Host "##vso[task.logissue type=error;]Failed to compile $projectName to executable."
            $script:allOk = $False
        } else {
            
            Write-Host "##[info]Updating environment path variables."
            $old_DYLD_LIBRARY_PATH = $env:DYLD_LIBRARY_PATH;
            $old_LD_LIBRARY_PATH = $env:LD_LIBRARY_PATH;
            $env:DYLD_LIBRARY_PATH += ":" (Join-Path $projectDirectory qir) + ":";
            $env:LD_LIBRARY_PATH += ":" (Join-Path $projectDirectory qir) + ":"; 
            
            Write-Host "##[info]Running $projectName..."
            Get-ChildItem (Join-Path qir *__Interop.exe) `
                | ForEach-Object { & $_ @Arguments}
            if  ($LastExitCode -ne 0) {
                Write-Host "##vso[task.logissue type=error;]$projectName encountered an error or failed during execution."
                $script:allOk = $False
            } else {
                Write-Host "##[info]QIR validation against $projectName was successful."
            }

            $env:DYLD_LIBRARY_PATH = $old_DYLD_LIBRARY_PATH;
            $env:LD_LIBRARY_PATH = $old_LD_LIBRARY_PATH;
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
# 'memory leak' means that the sample stalls when running and uses way too many system resources.
$qirProjects = @(
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples algorithms chsh-game CHSHGame.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples algorithms database-search DatabaseSearchSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples algorithms integer-factorization IntegerFactorization.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples algorithms oracle-synthesis OracleSynthesis.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples algorithms order-finding OrderFinding.csproj); Args = @("--index", "1") },
    @{ Path = (Join-Path $PSScriptRoot .. samples algorithms repeat-until-success RepeatUntilSuccess.csproj); Args = @("--gate", "simple", "--inputValue", "true", "--inputBasis", "PauliX", "--limit", "4", "--numRuns", "2") },
    @{ Path = (Join-Path $PSScriptRoot .. samples algorithms reversible-logic-synthesis ReversibleLogicSynthesis.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples algorithms simple-grover SimpleGroverSample.csproj); Args = @("--nQubits", "8") },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples algorithms sudoku-grover SudokuGroverSample.csproj); Args = @() },

    @{ Path = (Join-Path $PSScriptRoot .. samples azure-quantum grover Grover.csproj); Args = @("--nQubits", "3", "--idxMarked", "6") },
    @{ Path = (Join-Path $PSScriptRoot .. samples azure-quantum hidden-shift HiddenShift.csproj); Args = @("--patternInt", "6", "--registerSize", "4") },
    @{ Path = (Join-Path $PSScriptRoot .. samples azure-quantum ising-model IsingModel.csproj); Args = @("--nSites", "5", "--time", "5.0", "--dt", "0.1") },
    @{ Path = (Join-Path $PSScriptRoot .. samples azure-quantum parallel-qrng ParallelQrng.csproj); Args = @("--nQubits", "3") },
    @{ Path = (Join-Path $PSScriptRoot .. samples azure-quantum teleport Teleport.csproj); Args = @("--prepBasis", "PauliX", "--measBasis", "PauliX") },

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
    @{ Path = (Join-Path $PSScriptRoot .. samples getting-started simple-algorithms SimpleAlgorithms.csproj); Args = @("--nQubits", "4") }
    @{ Path = (Join-Path $PSScriptRoot .. samples getting-started teleportation TeleportationSample.csproj); Args = @() },

    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples machine-learning half-moons HalfMoons.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples machine-learning parallel-half-moons ParallelHalfMoons.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples machine-learning wine Wine.csproj); Args = @() },

    @{ Path = (Join-Path $PSScriptRoot .. samples numerics CustomModAdd CustomModAdd.csproj); Args = @() },
    # memory leak #@{ Path = (Join-Path $PSScriptRoot .. samples numerics EvaluatingFunctions EvaluatingFunctions.csproj); Args = @() },
    # memory leak #@{ Path = (Join-Path $PSScriptRoot .. samples numerics ResourceCounting ResourceCounting.csproj); Args = @() },

    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation h2 command-line H2SimulationSampleCmdLine.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples simulation hubbard HubbardSimulationSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation ising adiabatic AdiabaticIsingSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation ising generators IsingGeneratorsSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation ising phase-estimation IsingPhaseEstimationSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation ising simple SimpleIsingSample.csproj); Args = @() },
    # not compatible #@{ Path = (Join-Path $PSScriptRoot .. samples simulation ising trotter-evolution IsingTrotterSample.csproj); Args = @() },
    @{ Path = (Join-Path $PSScriptRoot .. samples simulation qaoa QAOA.csproj); Args = @("--numTrials", "20") }
)

# TODO: this temporary override to only run against a single sample is temporary. It is only here until the testing framework can be validated.
#$qirProjects = @(
#)

Write-Host "##[info]Beginning Microsoft.Quantum.Qir.CommandLineTool installation.";

if (-not (Get-Command qir-cli -ErrorAction SilentlyContinue)) {
    $version = ($Env:NUGET_VERSION -split "-")[0] + "-alpha"
    Write-Host "##[info]Going to install Microsoft.Quantum.Qir.CommandLineTool.$version.";
    dotnet tool install Microsoft.Quantum.Qir.CommandLineTool --version $version -g
    if  ($LastExitCode -ne 0) {
        Write-Host "##[error]Failed to install Microsoft.Quantum.Qir.CommandLineTool.$version.";
        $script:allOk = $False
    } else {
        Write-Host "##[info]The Microsoft.Quantum.Qir.CommandLineTool.$version has been installed.";
    }
} else {
    Write-Host "##[info]The Microsoft.Quantum.Qir.CommandLineTool is already installed.";
}

if ($allOk) {
    Write-Host "##[info]Running Validation of QIR against Samples."
    $qirProjects `
        | ForEach-Object { Build-One $_.Path $_.Args }
    
    if (-not $allOk) {
        throw "At least one sample failed build. Check the logs."
    } else {
        Write-Host "##[info]Validation of QIR against Samples was successful."
    }
} else {
    throw "The Microsoft.Quantum.Qir.CommandLineTool did not install successfully."
}
