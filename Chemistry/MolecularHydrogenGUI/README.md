# H₂ Simulation GUI Demo #

This sample finds the equilibrium bonding distance of molecular Hydrogen. Estimates of the ground
state energy are a funciton of bond distance are computed using the quantum phase estimation 
algorithm, using Hamiltonian simulation by a Trotter-Suzuki integrator.

## Prerequisites ##

On top of [.NET core](https://www.microsoft.com/net/learn/get-started/macos), 
this demo uses the [Electron](https://github.com/electron/electron) framework to display the results of simulating H₂.
Since Electron is distributed using the Node.js Package Manager (npm), we must therefore install npm first.

**Windows** npm can be installed using chocolatey:

```powershell
PS> choco install nodejs
```

Alternatively, manual downloads are available from [nodejs.org](https://nodejs.org/en/).

**macOS** Download and run the Node.js installer package from [nodejs.org](https://nodejs.org/en/).

**Linux** Most distributions include Node.js and npm, but that version might be out of date.
To ensure that you have the latest version, we recommend using the packages provided by NodeSource:

```bash
curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Once npm is installed, we can then install all Node.js packages required for the front end using `npm install`:

```bash
$ npm install
```

## Running the Demo ##

Once pre-reqs are ready, to run the demo from the command line use  `dotnet` to start the project:

```bash
$ dotnet run
```
