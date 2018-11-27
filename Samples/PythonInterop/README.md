# Python Interoperability #

This sample demonstrates the use of Python to call into Q# by using the [QInfer](http://qinfer.org/) and [QuTiP](http://qutip.org/) Python libraries to study the behavior of a Q# operation.

**NB**: This sample is currently a preview, and is supported on Windows only.

## Installation ##

As this sample demonstrates using Q# and Python together, we'll need to install a few more things than for Q# itself:

- **Python 3.5** or later
- **Jupyter Notebook**
- Python packages used by this sample: **Python.NET**, **NumPy**/**SciPy**, **Matplotlib**, **QInfer**, and **QuTiP**
- **.NET Framework 4.7.1** or later is required for this sample.
  This version of the .NET Framework is installed with Windows 10 Fall Creators Update (launched in October 2017), but you may need to install it separately if you are on an earlier version of Windows.
  [See below](#net-framework-versions) to check your installed version, and how to update if needed.

We recommend installing the [**Anaconda distribution**](https://www.anaconda.com/) of Python, as it includes NumPy, SciPy, Jupyter, and tools to make it easier to install and manage Python packages.

### Installing Anaconda ###

- Download the [latest version of Anaconda](https://www.anaconda.com/download/#windows), making sure to select the Python 3.5 or later version and not the version for Python 2.7.
- Run the Anaconda installer, and make sure to select *Add to PATH* during the installation.

To check that Anaconda was installed correctly, run `python` from your favorite command line.
You should see something like the following:

```powershell
PS> python
Python 3.6.2 |Anaconda custom (64-bit)| (default, Sep 19 2017, 08:03:39) [MSC v.1900 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license" for more information.
>>>
```
Type `exit()` and press *Enter* to quit Python and return to your command line.

The Anaconda distribution installed above comes with Jupyter Notebook by default, but we recommend installing the `nb_conda` extension as well:

```powershell
PS> conda install nb_conda
```

### Installing Required Python Packages ###

Once you have Anaconda installed, run the following from your favorite command line to install the environment for this sample:

```powershell
> cd Samples/PythonInterop
> conda env create -f environment.yml
```

#### [Optional] Testing the New Conda Environment ####

To use the new environment from the command line, we must activate it with the `activate` command.
For instance, to find the path at which the new environment was created, we can run the following commands:

```powershell
PS> cmd
> activate qsharp-samples
(qsharp-samples) > python -c "import sys; print(sys.executable)"
C:\Users\<username>\AppData\Local\Continuum\anaconda3\envs\qsharp-samples\python.exe
```

Note that `cmd` is required as `activate` is not currently supported from within PowerShell; if the `(qsharp-samples)` prompt does not appear, you may need to run the above commands from within `cmd`.

In any case, we will not be executing Jupyter inside this environment directly, but we will instead rely on `nb_conda` as installed above.
Thus, you must deactivate `qsharp-samples` to get back to the `root` environment.
This is done with the `deactivate` command:

```powershell
(qsharp-samples) > deactivate
```

### Running the Sample ###

Once everything is installed, from the command line build the PythonInterp project using dotnet:

```powershell
PS> cd Samples\PythonInterop
PS> dotnet build
```

Then run `jupyter notebook` to start the Jupyter Notebook interface in your web browser:

```powershell
PS> jupyter notebook
```

On the browser
- Select the `tomography-sample.ipynb` notebook in your browser to view the sample.
- From the `Kernel` menu, change to the `Python [conda env: qsharp-samples]` kernel.
- You are ready to start running the `tomography-sample` notebook.

## Troubleshooting ##

### `raw write() returned invalid length` ###

You may see an error message similar to the one below:

```
File "C:\Users\<username>\AppData\Local\Continuum\anaconda3\envs\qsharp-samples\lib\site-packages\pip\_vendor\colorama\ansitowin32.py", line 141, in write
    self.write_and_convert(text)
  File "C:\Users\<username>\AppData\Local\Continuum\anaconda3\envs\qsharp-samples\lib\site-packages\pip\_vendor\colorama\ansitowin32.py", line 169, in write_and_convert
    self.write_plain_text(text, cursor, len(text))
  File "C:\Users\<username>\AppData\Local\Continuum\anaconda3\envs\qsharp-samples\lib\site-packages\pip\_vendor\colorama\ansitowin32.py", line 175, in write_plain_text
    self.wrapped.flush()
OSError: raw write() returned invalid length 134 (should have been between 0 and 67)
    9% |###                             | 348kB 2.7MB/s eta 0:00:02
```

This is a known issue with running Python 3.5 from within VS Code.
If you encounter this error, run the sample from a PowerShell window outside of VS Code.

### `ImportError: No module named 'Microsoft.Quantum.Samples'; 'Microsoft.Quantum' is not a package` ###

If there is an error loading a .NET assembly into Python, this may manifest as an `ImportError` later in the notebook when you attempt to import namespaces exposed in that assembly.
This may happen because the assemblies defining your Q# operations and functions did not build properly.
To check this, run `dotnet build` again.

The next most often cause of this problem is a version number mismatch between the version of the Quantum Development Kit expected by the Python interoperability package and the version referenced by the assembly that you are loading.
If the `qsharp` Python package successfully imports, you can check its version by running `print(qsharp.version)` from within Python.
To check if the `qsharp` package installed at all, please use the `conda list` command:

```bash
$ conda list -n qsharp-samples qsharp
```

This version number should agree with the version listed in [`PythonInterop.csproj`](./PythonInterop.csproj), up to that Python packages do not use the `-preview` notation.

If all else fails, you can see more detailed error messages by catching the exceptions raised by the .NET assembly loader:

```python
>>> import sys
>>> sys.path.append('./bin/Debug/netstandard2.0')
>>> import qsharp

>>> import clr
>>> asm = clr.AddReference('PythonInterop')
>>> try:
...     print(asm.DefinedTypes)
... except Exception as ex:
...     for loader_ex in ex.LoaderExceptions:
...         print(loader_ex)
```

### .NET Framework Versions ###

This sample uses *.NET Standard 2.0*, first supported by the .NET Framework as of version 4.7.1.
.NET Framework 4.7.1 can be installed on Windows 7 or later, and comes installed by default on Windows 10 Fall Creators Update and later.
To check if your installation of .NET Framework supports .NET Standard 2.0, run the following command in Windows PowerShell or PowerShell Core:

```powershell
PS> Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release | ForEach-Object { $_ -ge 461308 }
```

If your installation of .NET Framework supports .NET Standard 2.0, you will see the word `True` printed to the console.
Otherwise, please [update your installation of the .NET Framework](https://www.microsoft.com/net/download/dotnet-framework-runtime).
