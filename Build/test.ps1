# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

function Test-One {
    Param($project)

    Write-Host "##[info]Testing $project..."
    dotnet test (Join-Path $PSScriptRoot $project) `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        --logger trx `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:ASSEMBLY_VERSION

    if  ($LastExitCode -ne 0) {
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

Validate-Integrals

Test-One '../samples/tests/sample-tests'
Test-One '../samples/diagnostics/unit-testing'

if (-not $all_ok) {
    throw "At least one project failed to compile. Check the logs."
}

