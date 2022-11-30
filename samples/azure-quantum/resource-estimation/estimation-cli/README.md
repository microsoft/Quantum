# Resource estimation CLI tool

This sample shows how to build a resource estimation CLI tool that connects to
Azure Quantum and takes as input a QIR program.

## Setup

The tool requires the `azure-quantum` and `pyqir-generator` libraries in the
following version.  You can for example use conda to set this up:

```sh
conda create -y -n estimation-cli -c conda-forge python=3.7
conda activate estimation-cli
python -m pip install azure-quantum==0.27.238334
python -m pip install pyqir-generator==0.6.2
```

## Run the program

You can run the program as follows:

```sh
python estimate.py -r <Azure-Quantum-Resource-Id> -l <Azure-Quantum-Location> program.qir
```

where `<Azure-Quantum-Resource-Id>` and `<Azure-Quantum-Location>` is information
about your Azure Quantum workspace that can be obtained from its overview page.
