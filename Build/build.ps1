# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

function Build-One {
    param(
        $project
    );

    Write-Host "##[info]Building $project..."
    dotnet build $project `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:ASSEMBLY_VERSION

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

# IMPORTANT: Do not add projects to the blocklist without an explanation as to why,
#            and a path towards removing those projects from the blocklist in the future.
$buildBlockList = @(
    # The following solution contains projects that can only be executed by
    # submitting it to Azure Quantum Resource Estimator and therefore cannot be
    # build
    "../samples/azure-quantum/resource-estimation/resource-estimation.sln"
) | ForEach-Object { (Resolve-Path (Join-Path $PSScriptRoot $_)).Path };

Get-ChildItem (Join-Path $PSScriptRoot '..') -Recurse -Include '*.sln' `
    | Where-Object { $_.FullName -notin $buildBlockList }
    | ForEach-Object { Build-One $_.FullName }

if (-not $all_ok) {
    throw "At least one test failed execution. Check the logs."
}
