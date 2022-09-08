# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

& "$PSScriptRoot/set-env.ps1"

enum ProjectKind {
    Executable;
    Library;
    Test;
}

function Get-ProjectKind() {
    <#
        .SYNOPSIS
            Attempts to test if a given project is an executable or
            library project. Note that since this cmdlet doesn't
            resolve MSBuild logical properties, detection is not
            perfect.
    #>

    param(
        [string]
        $Path
    );

    # Check if the path is relative; if so, join with where
    # the module is stored.
    if (-not [IO.Path]::IsPathRooted($Path)) {
        $Path = Join-Path $PSScriptRoot $Path;
    }

    # Load the project XML itself.
    $project = ([xml](Get-Content $Path)).DocumentElement;

    # Does the project say that it's an Exe?
    $outputType = $project.PropertyGroup.OutputType;
    if ($outputType -eq "Exe") {
        return [ProjectKind]::Executable;
    }

    # Does the project depend on Microsoft.Quantum.Xunit?
    # Then it's a test project.
    $testReferences = $project.ItemGroup.PackageReference `
        | Where-Object { $_.Include -eq "Microsoft.Quantum.Xunit" };
    if ($testReferences.Count -gt 0) {
        return [ProjectKind]::Test;
    }

    # By default, projects are libraries, so fall back at this point.
    return [ProjectKind]::Library;
}

function Invoke-Project() {
    param(
        [string]
        $Path,

        [array]
        $AdditionalArgs = @()
    );

    # Check if the path is relative; if so, join with where
    # the module is stored.
    if (-not [IO.Path]::IsPathRooted($Path)) {
        $Path = Join-Path $PSScriptRoot $Path;
    }

    Write-Verbose "##[info]Running dotnet project at $Path...";
    $commonArgs = Get-CommonDotNetArguments;
    dotnet run --project $Path @commonArgs `-- @AdditionalArgs;

    if ($env:FORCE_CLEANUP -eq "true") {
        # Force cleanup of generated bin and obj folders for this project.
        Write-Host "##[info]Cleaning up bin/obj from $(Split-Path $Path -Parent)..."
        Get-ChildItem -Path (Split-Path $Path -Parent) -Recurse | Where-Object { ($_.name -eq "bin" -or $_.name -eq "obj") -and $_.attributes -eq "Directory" } | Remove-Item -recurse -force
    }
}

function Get-CommonDotNetArguments {
    return @(
        "-c", $Env:BUILD_CONFIGURATION,
        "-v", $Env:BUILD_VERBOSITY
    );
}

function Get-CommonMSBuildArguments {
    return @(
        "/property:DefineConstants=$Env:ASSEMBLY_CONSTANTS",
        "/property:Version=$Env:ASSEMBLY_VERSION"
    );
}

function Convert-ObjectsToHashtable {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $Item
    );

    begin {
        $ht = @{};
    }

    process {
        $ht[$Item.Key] = $Item.Value
    }

    end {
        $ht | Write-Output
    }
}