#!/bin/env python
# -*- coding: utf-8 -*-
##
# __main__.py: Main script for the Q# interoperability package.
##
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
##

import qsharp

from qsharp.tomography import single_qubit_process_tomography
from Microsoft.Quantum.Primitive import I

qsim = qsharp.QuantumSimulator()
noise_channel = qsim.get(I)
estimation_results = single_qubit_process_tomography(qsim, noise_channel, n_measurements=2000)

print(estimation_results['est_channel'])
