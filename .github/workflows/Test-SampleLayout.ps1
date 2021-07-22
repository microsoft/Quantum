# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

<#
    .SYNOPSIS
        Tests that the layout for different sample directories is correct
        (e.g.: that samples have associated README.md files, are linked
        to from binder-index.md, and so forth).
#>
param();

$InCI = "$Env:CI" -eq "true" -and "$Env:GITHUB_WORKFLOW" -ne "";

## Install Dependencies ##

# If running in CI, install PowerHTML so that we can parse HTML later.
if ($InCI) {
    If (-not (Get-Module -ErrorAction Ignore -ListAvailable PowerHTML)) {
        Install-Module PowerHTML -Force -ErrorAction Stop -Scope CurrentUser;
      }
      Import-Module -ErrorAction Stop PowerHTML
}

## Path Definitions ##

$RepoRoot = Join-Path $PSScriptRoot ".." ".." | Resolve-Path;
$SamplesRoot = Join-Path $RepoRoot "samples" | Resolve-Path;
$BinderIndex = Join-Path $RepoRoot ".\binder-index.md" | Resolve-Path;

## Private Cmdlets ##

function Write-GitHubWarning {
    param(
        $Message,
        $Path = $null
    );

    if ($InCI) {
        $file = $null -ne $Path ? " file=$Path" : "";
        Write-Host "::warning$file::$Message";
    } else {
        Write-Warning "${Path}: $Message"
    }
}

function Get-ParentPaths() {
    [CmdletBinding()]
    param(
        $Path,
        $UpperBound = $null
    );

    $item = Get-Item $Path;

    # Is $Path a file? If so, find its directory and write it out.
    if (-not $item.PSIsContainer) {
        return Get-ParentPaths -Path (Split-Path $Path -Parent) -UpperBound $UpperBound;
    }

    # If $Path is a directory, write it out and recurse if we haven't already
    # hit our upper-bound.
    Write-Output $item;
    if ($null -ne $UpperBound) {
        # Join-Path with "" normalizes whether paths end in a / or not.
        $resolvedItem = Resolve-Path (Join-Path $Path "") | Get-Item;
        $resolvedBound = Resolve-Path (Join-Path $UpperBound "") | Get-Item;
        if ($resolvedItem.FullName -eq $resolvedBound.FullName) {
            return;
        }
    }
    $parent = $item.Parent;

    if ($null -ne $parent) {
        Get-ParentPaths $parent -UpperBound $UpperBound | Write-Output;
    }
}

function Test-SampleHasReadme() {
    [CmdletBinding()]
    param(
        $Path
    );

    foreach ($parent in Get-ParentPaths $Path -UpperBound $SamplesRoot) {
        # Does $parent have a README.md file?
        $readmePath = (Join-Path $parent "README.md");
        if (Test-Path $readmePath) {
            # If so, does it have any front matter? For now, we just check for
            # it to start with "---", but that could be improved.
            if ((Get-Content -Raw $readmePath).StartsWith("---")) {
                $true | Write-Output;
                return;
            }
        }
    }
    $false | Write-Output;

}

## Main Script ##

# Find each csproj and ipynb file in the samples folder. We need to make sure
# each has a README.md file with front matter somewhere up the tree.
$sampleProjects = Get-ChildItem -Path $SamplesRoot -Include *.csproj, *.ipynb -Recurse `
    | Where-Object {
        -not (git check-ignore $_)
    };
$samplesWithoutReadmes = $sampleProjects `
    | Where-Object { -not (Test-SampleHasReadme $_) };
$samplesWithoutReadmes
    | ForEach-Object {
        Write-GitHubWarning -Path $_ -Message "Project or notebook $_ does not seem to have a corresponding README.md with appropriate front-matter metadata.";
    };

if ($samplesWithoutReadmes.Count -gt 0) {
    Write-GitHubWarning -Message "$($samplesWithoutReadmes.Count) projects or notebooks may not have README.md files with front-matter.";
}

# Find each README.md with front matter and make sure that binder-index.md
# links to it.
$binderIndexHtml = ConvertFrom-Markdown $BinderIndex `
    | Select-Object -ExpandProperty Html `
    | ConvertFrom-Html;
$binderIndexUri = New-Object -TypeName System.Uri -ArgumentList @(, $BinderIndex)
$binderIndexLinks = $binderIndexHtml.SelectNodes("//a") `
    | ForEach-Object {
          New-Object -TypeName System.Uri -ArgumentList @(, $_.Attributes[0].Value, [System.UriKind]::RelativeOrAbsolute)
      } `
    | Where-Object { -not $_.IsAbsoluteUri } `
    | ForEach-Object {
          New-Object -TypeName System.Uri -ArgumentList @($binderIndexUri, $_) `
          | Select-Object -ExpandProperty LocalPath
      } `
    | Where-Object { $_.EndsWith("README.md") } `
    <# Fully resolve everything we find. #> `
    | ForEach-Object { Resolve-Path $_ | Get-Item | Select-Object -ExpandProperty FullName };
$readmesNotLinkedFromBinder = Get-ChildItem -Recurse -Include README.md `
    | Where-Object {
          (Get-Content $_ -Raw).StartsWith("---");
      } `
    | Where-Object {
          -not $binderIndexLinks.Contains($_.FullName);
      };
$readmesNotLinkedFromBinder | ForEach-Object {
    Write-GitHubWarning -Path $_ -Message "README.md file $_ has front matter, but isn't linked to from binder-index.md. This sample may be difficult to discover from aka.ms/try-qsharp.";
}


if ($readmesNotLinkedFromBinder.Count -gt 0) {
    Write-GitHubWarning "$($readmesNotLinkedFromBinder.Count) samples may not be linked from binder-index.md.";
}
