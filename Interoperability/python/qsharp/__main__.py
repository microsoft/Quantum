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

QSIM = qsharp.QuantumSimulator()
NOISE_CHANNEL = QSIM.get(I)
ESTIMATION_RESULTS = single_qubit_process_tomography(
    QSIM, NOISE_CHANNEL, n_measurements=2000)

print(ESTIMATION_RESULTS['est_channel'])
