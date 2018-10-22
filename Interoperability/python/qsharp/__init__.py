#!/bin/env python
# -*- coding: utf-8 -*-
##
# __init__.py: Root module for Q# interoperability package.
##
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
##

## IMPORTS ###################################################################

# Standard Library Imports #

from enum import IntEnum
from functools import partial, singledispatch
from abc import ABCMeta, abstractproperty
from random import randrange

# HACK: In order to make DLLs that we ship with visible to Python.NET
#       in the next step, we need to add the directory containing __file__
#       to sys.path.
import os.path
import sys
sys.path.append(os.path.split(__file__)[0])

# Version Information #
# We try to import version.py, and if not, set our version to None.
try:
    import qsharp.version
    __version__ = qsharp.version.version
except ImportError:
    __version__ = "<unknown>"

# CLR Imports #

import clr

import System.Threading.Tasks
import Microsoft.Quantum.Simulation.Simulators as mqss

# External Python Imports #

try:
    import colorama as ca
    ca.init()

    SIMULATOR_COLOR = ca.Fore.BLUE + ca.Back.WHITE
    RESET_COLOR = ca.Style.RESET_ALL
except:
    ca = None
    SIMULATOR_COLOR = ""
    RESET_COLOR = ""

try:
    import qutip as qt
except:
    qt = None

try:
    from IPython.display import display
except:
    def display(value):
        pass

import qsharp.tomography
from qsharp.clr_wrapper import *


## ENUMERATIONS ##############################################################

class SampleableEnum(IntEnum):
    """
    Extends integer-valued enumerations to allow for uniformly sampling from
    enumeration members.
    """
    @classmethod
    def random(cls):
        """
        Returns a member of the enumeration uniformly at random.
        """
        return cls(randrange(len(cls)))

class Pauli(SampleableEnum):
    """
    Represents the `Pauli` Q# type.
    """
    I = 0
    X = 1
    Y = 2
    Z = 3

    def as_qobj(self):
        """
        Returns a representation of the given Pauli operator as a QuTiP
        Qobj instance.
        """
        if qt is None:
            raise RuntimeError("Requires QuTiP.")
        if self == Pauli.I:
            return qt.qeye(2)
        elif self == Pauli.X:
            return qt.sigmax()
        elif self == Pauli.Y:
            return qt.sigmay()
        else:
            return qt.sigmaz()

class Result(SampleableEnum):
    """
    Represents the `Result` Q# type.
    """

    #: Represents a measurement corresponding to the $+1 = (-1)^0$ eigenvalue
    #: of a Pauli operator.
    Zero = 0

    #: Represents a measurement corresponding to the $-1 = (-1)^1$ eigenvalue
    #: of a Pauli operator.
    One = 1

## FUNCTIONS #################################################################

@singledispatch
def wrap_clr_object(clr_object):
    return WrappedCLRObject(clr_object)

@wrap_clr_object.register(type(None))
def _(none):
    return None

@wrap_clr_object.register(System.Threading.Tasks.Task)
def _(clr_object):
    return Task(clr_object)

## CLASSES ###################################################################

class SimulatorOutput(object):
    """
    Wraps a string for pretty-printing to Jupyter outputs.
    """
    @classmethod
    def display_output(cls, data):
        display(cls(data))

    def __init__(self, data):
        self.data = data

    def __repr__(self):
        return repr(self.data)
    def __str__(self):
        return "{}[Simulator]{} {}".format(
            SIMULATOR_COLOR, RESET_COLOR, self.data
        )

    def _repr_html_(self):
        return """
<pre class="simulator-output">{}</pre>
""".format(self.data)

class Task(WrappedCLRObject):
    _detailed_repr = False

    @property
    def _friendly_name(self):
        return "Asynchronous {} Task".format(
            self.clr_type.GetGenericArguments()[0]
        )

    def result(self):
        # Wait for the response first. This should be implied by self.Result,
        # but we've seen some bugs occur related to that.
        self.clr_object.Wait()
        return wrap_clr_object(self.clr_object.Result)

class Simulator(WrappedCLRObject):
    _friendly_name = "Simulator"

    def __init__(self, clr_simulator):
        if isinstance(clr_simulator, CLR_METATYPE):
            clr_simulator = clr_simulator()
        super(Simulator, self).__init__(clr_simulator)

        # Register a delegate to handle Message calls.
        self.clr_object.OnLog += SimulatorOutput.display_output

    def get(self, clr_type):
        return Callable(self, self.clr_object.Get[clr_type, clr_type]())

    def run(self, clr_type, *args):
        if isinstance(clr_type, Callable):
            # Check if the passed in type is already wrapped in a Callable Python
            # class.
            return clr_type(*args)
        else:
            # We need to get the callable ourselves, then.
            callable = self.get(clr_type)
            return callable(*args)

class QuantumSimulator(Simulator):
    _friendly_name = "Quantum Simulator"
    def __init__(self):
        super(QuantumSimulator, self).__init__(mqss.QuantumSimulator)

class Callable(WrappedCLRObject):
    _detailed_repr = False
    _parent = None
    _include_plain_repr = False
    
    @property
    def _friendly_name(self):
        # TODO: extract operation signature!
        return self.ToString()

    def __init__(self, parent, clr_callable):
        self._parent = parent
        super(Callable, self).__init__(clr_callable)

    def __call__(self, *args):
        output = self.clr_object.Run(
            unwrap_clr(self._parent),
            *map(unwrap_clr, args)
        )
        
        if isinstance(type(output), CLR_METATYPE):
            # Try to wrap the output as best as we can.
            # We provide convenience wrappers for a few, so we call the
            # single-dispatched convenience function above.
            return wrap_clr_object(output)
        else:
            return output
