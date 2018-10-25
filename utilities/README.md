# Quantum Development Kit Utilities #

## qdk-migrate.ps1 ##

> This script requires Windows PowerShell or PowerShell Core to run.
> Windows PowerShell comes pre-installed with Windows 10.
> Download PowerShell Core for Windows, macOS, or Linux at https://github.com/PowerShell/PowerShell.

This script helps migrate projects from version 0.2 of the Quantum Development Kit to use version 0.3.
Full documentation can be obtained by running one of the following commands:

```powershell
Get-Help ./qdk-migrate.ps1
Get-Help -Online ./qdk-migrate.ps1
```

## updateQDKversion.sh ##

> This script requires Bash to run.
> Bash comes pre-installed with macOS, most Linux distributions, and with Windows Subsystem for Linux.
> To install Bash natively on Windows, we recommend using the version distributed with [Git for Windows](https://git-scm.com/download/win).

This script updates NuGet package references to the Quantum Development Kit to use a particular version.
For example, the following command updates all C# projects in the current directory to use version 0.3.1809.1-preview of the Quantum Development Kit.

```bash
./updateQDKVersion.sh 0.3.1809.1-preview
```
