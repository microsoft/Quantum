# Quantum Development Kit Utilities

## qdk-migrate.ps1

> This script requires Windows PowerShell or PowerShell Core to run.
> Windows PowerShell comes pre-installed with Windows 10.
> Download PowerShell Core for Windows, macOS, or Linux at https://github.com/PowerShell/PowerShell.

This script helps migrate projects from version 0.2 of the Quantum Development Kit to use version 0.3.
Full documentation can be obtained by running one of the following commands:

```powershell
Get-Help ./qdk-migrate.ps1
Get-Help -Online ./qdk-migrate.ps1
```

## updateQDKversion.sh

> This script requires Bash to run.
> Bash comes pre-installed with macOS, most Linux distributions, and with Windows Subsystem for Linux.
> To install Bash natively on Windows, we recommend using the version distributed with [Git for Windows](https://git-scm.com/download/win).

This script updates NuGet package references to the Quantum Development Kit to use a particular version.
For example, the following command updates all C# projects in the current directory to use version 0.3.1809.1-preview of the Quantum Development Kit.

```bash
./updateQDKVersion.sh 0.3.1809.1-preview
```

## InvokeNWChem.psm1

> This module requires Windows PowerShell or PowerShell Core to run.
> Windows PowerShell comes pre-installed with Windows 10.
> Download PowerShell Core for Windows, macOS, or Linux at https://github.com/PowerShell/PowerShell.

This PowerShell module provides functionality for invoking [NWChem](https://nwchemgit.github.io/) using [Docker](https://docker.com/), and for using NWChem to produce [Broombridge](https://docs.microsoft.com/azure/quantum/user-guide/libraries/chemistry/schema/broombridge) documents.
To use this PowerShell module, first import it using the [`Import-Module`](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/import-module) command:

```powershell
cd Quantum/utilities
Import-Module InvokeNWChem.psm1
```

Once imported, additional documentation is available using the `Get-Help` command:

```powershell
Get-Help Invoke-NWChemImage
Get-Help Convert-NWChemToBroombridge
```

For more details about how to install prerequisites and use this module with the quantum chemistry library, please see the following pages:

- [Chemistry Library Installation and Validation](https://docs.microsoft.com/azure/quantum/user-guide/libraries/chemistry/installation)
- [End-to-end with NWChem](https://docs.microsoft.com/azure/quantum/user-guide/libraries/chemistry/samples/end-to-end)
