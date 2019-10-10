# Python Integration demo #

This demo shows how to use the `qsharp.chemistry` module to
load a Broombridge schema file into Python, encode it and simulate
its evolution using Trotterization in Q#.

Detailed information of what you can do using the chemistry module
can be found inside [chemistry_sample.py](./chemistry_sample.py).

## Pre-reqs.

This module depends on having Python, the `qsharp` module, and the IQ# kernel installed
on your machine. For detailed installation instructions, please visit
https://docs.microsoft.com/en-us/quantum/install-guide/python

## Running the demo.

From a command line, run:
```
python chemistry_sample.py
```

The first time you run the sample you might see errors like this when the script starts:
```
fail: Microsoft.Quantum.IQSharp.Workspace[0]
      QS5022: No identifier with that name exists.
```
these are known and are safe to ignore.

If the script runs successfully, you should see this message in the output.
```
Trotter simulation complete. (phase, energy): (-0.4150803744654529, -1.1365353821636321)
```
