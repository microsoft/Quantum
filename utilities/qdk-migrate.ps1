<#

    .SYNOPSIS
        This command migrates a project to version 0.3 of the Q# language
        and the Quantum Development Kit.

    .NOTES
        This command replaces the existing Q# source code with new
        source code formatted using 0.3 syntax. The original source code
        is stored in a backup folder under the obj/qsharp folder.

    .PARAMETER Version
        Version of the Quantum Development Kit package to migrate the
        project to.

    .PARAMETER Project
        Path to a C# project file that contains Q# code to be migrated.
        If not set, defaults to migrating C# projects in the current
        directory.

    .PARAMETER Force
        If set, the project will be migrated even if it does not build
        in its current state. This is useful, for instance, when migrating
        a 0.2 project that depends on a project that has already been
        migrated.

    .EXAMPLE
        PS> ./qdk-migrate.ps1

        Migrates a C# project in the current directory to use
        a 0.3-compatible version of the Quantum Development Kit.

    .EXAMPLE
        PS> ./qdk-migrate.ps1 -Force ./src/project-name/ProjectName.csproj

        Migrates the C# project located at `./src/project-name/ProjectName.csproj`
        to a 0.3-compatible version of the Quantum Development Kit,
        even if it does not currently build.

    .INPUTS
        None

    .OUTPUTS
        None

    .LINK
        https://review.docs.microsoft.com/en-us/quantum/relnotes/0.3-migration

#>

[CmdletBinding()]
param(
    [switch] $Force,

    [Parameter(Position=1)]
    $Project = (Get-ChildItem *.csproj),

    [Parameter(Position=2)]
    [string]
    $Version = "0.0.1808.2904-preview"
)

Write-Host ""
Write-Host "This script will migrate project '$Project' to QDK v0.3."
Write-Host ""
Write-Host "All the q# files will be migrated to the new syntax,"
Write-Host "and will be reformated in the process (no information"
Write-Host "will be lost and the original version can be found at "
Write-Host "obj\qsharp\.backup)."
Write-Host ""
Read-Host "Press ENTER to continue..."


# Make sure we start with a working project:
dotnet build $Project
if ($LastExitCode -ne 0) {
    if ($Force) {
        Write-Warning "Project $Project is failing to build. Continuing migration due to '-Force'."
    } else {
        Write-Host ""
        Write-Error "Project $Project migration failed."
        Write-Host "The project is not building correctly as it-is."
        Write-Host "Please fix your project, then try again to migrate" -foreground Yellow
        Write-Host "or specify '-force' to skip this check." -foreground Yellow
        Write-Host ""
        exit 1
    }
}
dotnet clean $Project 

# Install the latest templates:
dotnet new --install "Microsoft.Quantum.ProjectTemplates.$Version.nupkg"

# Update the project to the latest nugets:
function update-package {
    Param($pkg)

    if (Select-String -pattern $pkg -path $Project -quiet) 
    {
        dotnet add $Project package $pkg -v $Version
    }
}

update-package "Microsoft.Quantum.Development.Kit"
update-package "Microsoft.Quantum.Canon"
update-package "Microsoft.Quantum.Xunit"

# Migrate to new syntax:
dotnet restore $Project 
dotnet msbuild $Project /t:qsharpFormat

# Try to build once upgraded:
dotnet build $Project 
if ($LastExitCode -ne 0) {
    Write-Host ""
    Write-Warning "Your project is now migrated to use 0.3 syntax,"
    Write-Warning "however, it is failing to compile."
    Write-Host ""
    Write-Host "A typical reason for this is that the new q# compiler"
    Write-Host "requires user-defined types to be explicitly unwrapped when"
    Write-Host "trying to use them as their base type. For more information: "
    Write-Host "TODO:URL"
    Write-Host ""
    Write-Host "Please correct these build errors to complete your migration."
    exit 1
} else {
    Write-Host ""
    Write-Host "All set. Your project has now been migrated to 0.3 syntax."
    exit 0
}
