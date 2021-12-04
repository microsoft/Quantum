# Installing Optional Dependencies for the Gate Counting Sample

The **GateCount** sample can be run as a traditional command-line program with no further dependencies than for the chemistry library itself.
That said, the **GateCount** sample also demonstrates how to use Q# in other workflows, such as a traditional data science or business analytics process.
In both cases, this sample uses the open-source PowerShell Core environment to interoperate between Q# programs and other workflows.

## Summary

This sample can be used in a variety of different ways, including as a traditional command-line tool, and as a part of a larger data science or business analytics workflow.

To use this sample as a traditional command-line tool, use `dotnet run`:

```bash
dotnet run
```

Specific sets of integrals can be specified using the `--path` option (`-p`) and the `--format` option (`-f`):

```bash
dotnet run -- --path=../IntegralData/YAML/h2.yaml --format=Broombridge
```

For more options, run `dotnet run -- -?`.

To use this sample from PowerShell, import the `get-gatecount.dll` assembly as a module, and use the `Get-GateCount` command, replacing `<runtime>` with either `win10-x64`, `osx-x64`, or `linux-x64`:

```powershell
dotnet publish --self-contained -r <runtime>
Import-Module ./bin/Debug/net6.0/<runtime>/publish/get-gatecount.dll
Get-GateCount -Path ../IntegralData/YAML/h2.yaml -Format Broombridge
```

When using this sample from PowerShell, you can pipe the results into an Excel spreadsheet using the [ImportExcel package](https://github.com/dfinke/ImportExcel):

```powershell
Get-ChildItem ../IntegralData/YAML/LiHData/*.yaml | Get-GateCount -Format Broombridge | Export-Excel out.xlsx
Invoke-Item $$
```

Alternatively, you can pipe the results into the provided Python plotting tool using the [posh-tex package](https://www.cgranade.com/posh-tex/):

```powershell
Get-ChildItem ../IntegralData/YAML/LiHData/*.yaml | Get-GateCount -Format Broombridge | ./Out-Plot.ps1
```

For more options and documentation, run `Get-GateCount -?`.

## Installing Optional Dependencies

As noted above, this sample can be used with other workflows, using tools like Python, Excel, and PowerShell Core.
To use these features requires some additional dependencies beyond the traditional command-line workflow described above.
In this section, we describe these additional dependencies.

### Windows PowerShell and PowerShell Core

Similarly to the split between the .NET Framework and .NET Core platforms, PowerShell is available as Windows PowerShell or as the cross-platform PowerShell Core environment.
This sample has been developed to run against PowerShell Core, and may not work from within Windows PowerShell.

If you already have PowerShell, but aren't sure if you have Windows PowerShell or PowerShell Core, you can check what edition of PowerShell you have by running the following command from within PowerShell:

```PowerShell
$PSVersionTable.Edition
```

If this command returns `Desktop`, then you are running Windows PowerShell and will need to install PowerShell Core 6.0 or later.
If this command returns `Core`, you can proceed with the rest of the installation procedure.

If you need to install PowerShell Core, either because you do not have PowerShell at all, or because you have Windows PowerShell, download the installer appropriate for your operating system from the [GitHub site](https://github.com/PowerShell/PowerShell#get-powershell) for PowerShell Core.
Note that by default, PowerShell Core will install side-by-side with any other shells that you may have.

### Installing Required PowerShell Modules

The **GateCount** sample demonstrates how to export gate count data for further use in a Python-based data science process, and how to export gate count data into an Excel-based business analytics process.
Each of these integrations relies on a third-party PowerShell module that handles the appropriate exporting of data for us.

To install PowerShell modules, use the `Install-Module` command.
For instance, to install the [ImportExcel package](https://github.com/dfinke/ImportExcel), run the following from within PowerShell Core:

```PowerShell
Install-Module -Scope CurrentUser ImportExcel
```

This will prompt you to download and install the package from the PowerShell Gallery, a NuGet repository containing community-developed commands for PowerShell.
The `-Scope CurrentUser` parameter tells the installer to make the new package available only to the current user, such that you do not need administrator privileges.

> [!WARNING]
> PowerShell modules are *not* shared between Windows PowerShell and PowerShell Core installations.
> If you already have a module for Windows PowerShell, you will need to reinstall it from within PowerShell Core to make use of its functionality.

The integration between PowerShell and Python data science workflows is provided by the [posh-tex package](http://www.cgranade.com/posh-tex), so we'll install it as well:

```PowerShell
Install-Module -Scope CurrentUser posh-tex
```

Once installed, PowerShell will scan each module for what commands are made available, and will in most cases be able to automatically import modules when you call commands.
If you would like to manually make commands from a module available in your current session, use the `Import-Module` command.
For instance, the following lists all commands provided by the `posh-tex` module:

```PowerShell
Import-Module posh-tex
Get-Command -Module posh-tex
```

> [!TIP]
> The `Import-Module` command is also made available under the shorthand alias `ipmo`.
> The `impo` shorthand can be read as a concatenation of `ip` (Import) and `mo` (Module), making it easier to remember aliases.
> Similarly, `in` is short for "Install", so `inmo` is an alias for `Install-Module`.

### Installing a Python Environment

We recommend using this example with the [Anaconda distribution](https://www.anaconda.com/).
To install Anaconda, follow the instructions provided on the [download page](https://www.anaconda.com/download/).
On Windows, we recommend installing Anaconda using the Chocolatey package manager:

```PowerShell
choco install anaconda3
```

> [!WARNING]
> By default, Anaconda is not added to your PATH.
> You may therefore see an error such as "python : The term 'python' is not recognized as the name of a cmdlet, function, script file, or operable program."
> In this case, make sure to run `conda activate` before launching PowerShell in order to make `python` available.
> For instance, if you are using Bash on macOS or Linux, the following will print the path used to run Python:
>
> ```bash
> conda activate
> pwsh
> Get-Command python
> ```

## Using PowerShell with the **GateCount** Sample

Once you have installed the prerequisites above, the **GateCount** sample can be imported into PowerShell using the `dotnet publish` and `Import-Module` commands.
To do so, replace `<runtime>` in the snippet below with either `win10-x64`, `linux-64`, or `osx-x64`, depending on your operating system.

```PowerShell
cd Samples/GateCount
dotnet publish --self-contained -r <runtime>
Import-Module ./bin/Debug/net6.0/<runtime>/publish/get-gatecount.dll
```

The `Get-GateCount` command is now available, and can be used to estimate costs for evolution under different quantum chemistry Hamiltonians.
The `Get-GateCount` command takes as an input the name of a Hamiltonian file to load along with a parameter indicating the serialization format for that file.
These parameters are listed by running the help functionality built into PowerShell:

```PowerShell
Get-Help Get-GateCount
```

In particular, we note that the `-Path` parameter accepts pipeline input:

```PowerShell
Get-Help Get-GateCount -Parameter Path
```

This means that you can provide multiple files to be analyzed at once by piping a command that produces files into the `Get-GateCount` command.
Most typically, this will be the `Get-ChildItem` command, which lists all files matching a particular pattern.

> [!TIP]
> The `Get-ChildItem` is by default made available under the alias `gci` (`g` for "Get" and `ci` for "ChildItem"), as well as aliases corresponding to traditional shells (`ls` and `dir`).

For instance, to load all Broombridge format files provided with the chemistry package:

```PowerShell
$results = Get-ChildItem ..\IntegralData\LiquidSelected\* | Get-GateCount -Format Liquid
```

This creates a new variable `$results` in the current PowerShell session.

> [!TIP]
> You can save `$results` to disk and load back from disk to help you resume your work if you lose your session.
> For instance, to export gate count data to JSON, use the `ConvertTo-Json` command to perform the conversion, and `Set-Content` to save to disk.
> Importing uses `Get-Content` and `ConvertFrom-Json` instead:
>
> ```PowerShell
> $results | ConvertTo-Json | Set-Content results.json
> $results = Get-Content results.json | ConvertFrom-Json
> ```

From there, you can pipe `$results` into `Export-Excel` to make a spreadsheet:

```PowerShell
$results | Export-Excel out.xlsx
Invoke-Item $$
```

> [!TIP]
> The variable `$$` always refers to the last token in the previous command; in this case, `out.xlsx`.
> This makes `ii $$` a very useful shorthand for launching the most recently defined file, with `ii` standing for `Invoke-Item`.

You can also use the provided `Out-Plot.ps1` script to feed the gate counting results to Python using posh-tex:

```PowerShell
$results | ./Out-Plot.ps1
```

There are many more ways to use the **GateCount** sample with the rich automation packages provided for PowerShell.
Have fun!
