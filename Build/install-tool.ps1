## This script is temporary

Write-Host "##[info]Beginning qir-cli tool installation script";

if (-not (Get-Command qir-cli -ErrorAction SilentlyContinue)) {
    $version = ($Env:NUGET_VERSION -split "-")[0] + "-alpha"

    Write-Host "##[info]Going to install version $version of the command line tool.";

    dotnet tool install Microsoft.Quantum.Qir.CommandLineTool --version $version -g
    Write-Host "##[info]The qir-cli command has been installed with version $version";
} else {
    Write-Host "##[info]The qir-cli command is already installed.";
}

Write-Host "##[info]Ending qir-cli tool installation script";