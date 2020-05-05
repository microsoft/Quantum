# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

Get-ChildItem -recurse *.csproj, *.fsproj `
    | ForEach-Object { $_.Directory } `
    | Sort-Object `
    | Get-Unique `
    | ForEach-Object -Parallel { dotnet clean $_ };
