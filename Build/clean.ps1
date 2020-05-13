# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

Get-ChildItem -Recurse -Path ".." -Include *.csproj, *.fsproj `
    | ForEach-Object { $_.Directory } `
    | Sort-Object `
    | Get-Unique `
    | ForEach-Object {
        Write-Host "##[info] Cleaning $_.";
        dotnet clean $_ `
            --configuration $Env:BUILD_CONFIGURATION;
    };
