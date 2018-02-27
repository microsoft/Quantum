#!/bin/env python
# -*- coding: utf-8 -*-
##
# test_version.py: Checks that version metadata agrees with bundled
#     assemblies.
##
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
##

import qsharp
from distutils.version import LooseVersion

from nose.tools import eq_

def test_versions_match():
    """
    Check if Python and .NET assembly versions match.
    """
    asm = qsharp.QuantumSimulator().clr_type.Assembly
    asm_clr_version = asm.GetName().Version

    asm_version = LooseVersion(asm_clr_version.ToString())
    py_version = LooseVersion(qsharp.__version__)
    eq_(asm_version, py_version)
