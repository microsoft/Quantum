## This script is temporary

if (-not (Get-Command qir-cli -ErrorAction SilentlyContinue)) {
    $version = ($Env:NUGET_VERSION -split "-")[0] + "-alpha"
    dotnet tool install Microsoft.Quantum.Qir.CommandLineTool --version $version -g
    Write-Host "##[info]The qir-cli command has been installed.";
} else {
    Write-Host "##[info]The qir-cli command is already installed.";
}