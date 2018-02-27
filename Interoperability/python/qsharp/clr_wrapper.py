
#!/bin/env python
# -*- coding: utf-8 -*-
##
# clr_wrapper.py: Classes to wrap CLR objects to provide Jupyter integration.
##
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
##


## IMPORTS ###################################################################

# Standard Library Imports #

from abc import ABCMeta, abstractproperty
from random import randrange

# CLR Imports #

import clr
import System

# External Python Imports #

try:
    from IPython.display import display
except ImportError:
    def display(value):
        pass

## STYLESHEETS ###############################################################
# We load a custom stylesheet into Jupyter Notebook to allow formatting
# prettier CLR representation tables.
class Stylesheet(object):
    def __init__(self, style):
        self.style = style
    def _repr_html_(self):
        return "<style>\n{}\n</style>".format(self.style)
    def __repr__(self):
        return "" # We want to be invisible if we're not in Jupyter!

display(Stylesheet("""
    .clr-repr-table td {
        text-align: left;
    }

    div.output_area pre.simulator-output {
        border-left: solid 12px #409AE1;
        padding-left: 4px;
        margin-left: -4px
    }
"""))

## CONSTANTS #################################################################

# We find and record the metatype associated with Python representations of
# CLR types. Since this metatype is not directly exposed by the Python.NET
# API, we can find it by asking for the type of an Object type that we are
# guaranteed exists.

#: The metatype common to all Python representations of CLR types.
CLR_METATYPE = type(System.Object)

## CLASSES ###################################################################

class WrappedCLRObject(object):
    _detailed_repr = True
    _friendly_name = "Wrapped CLR Object"
    _include_plain_repr = True

    def __init__(self, clr_object):
        self._clr_object = clr_object

    @property
    def clr_object(self):
        return self._clr_object

    @property
    def clr_type(self):
        return self.clr_object.GetType()

    def __getattr__(self, attr):
        # Forward upper-cased attributes to the underlying CLR
        # object.
        if str.isupper(attr[0]):
            return getattr(self.clr_object, attr)
        else:
            # This is only called on last resort, so we can raise
            # the exception here without breaking anything.
            raise AttributeError("{0.__class__} object has no attribute {1}".format(self, attr))


    def __repr__(self):
        try:
            return "<{ty_self.__name__}({self.clr_type.FullName}) at 0x{id_self:x}>".format(ty_self=type(self), self=self, id_self=id(self))
        except:
            return "<{ty_self.__module__}{ty_self.__name__} at 0x{id_self:x}>".format(ty_self=type(self), id_self=id(self))

    def __str__(self):
        return self.clr_object.ToString()

    def _method_list(self):
        clr_type = self.clr_type
        methods = [
            "{0} {1}({2})".format(
                method.ReturnType.Name,
                method.Name,
                ", ".join(
                    "{param.ParameterType.Name}<{contents}> {param.Name}".format(
                        param=param,
                        contents=', '.join(map(str, param.ParameterType.GenericTypeArguments))
                    )
                    for param in method.GetParameters()
                )
            )
            for method in clr_type.GetMethods()
        ]

        if methods:
            return """
                <tr>
                    <td>
                        Methods
                    </td>

                    <td><pre>{}</pre></td>

                    {}
                </tr>
            """.format(
                methods[0],
                "\n".join(
                    "<tr><td></td><td><pre>{}</pre></td></tr>".format(method)
                    for method in methods[1:]
                )
            )
        else:
            return ""

    def _repr_html_(self):
        return """
        <strong>{self._friendly_name}</strong>
        <table class="clr-repr-table">
            {plain_repr}
            <tr>
                <td>
                    Python type
                </td>
                <td>
                    {ty_self.__module__}.{ty_self.__name__}
                </td>
            </tr>

            <tr>
                <td>
                    CLR type
                </td>
                <td>
                    {self.clr_type.FullName}
                </td>
            </tr>

            <tr>
                <td>
                    Assembly name
                </td>

                <td>
                    {self.clr_type.Assembly.FullName}
                </td>
            </tr>

            {method_list}
        </table>
        """.format(
            plain_repr="""
                <tr>
                    <td colspan="2">
                        <pre>{}</pre>
                    </td>
                </tr>
            """.format(self.clr_object) if self._include_plain_repr else "",
            ty_self=type(self),
            self=self,
            method_list=self._method_list() if self._detailed_repr else ""
        )

def unwrap_clr(py_value):
    return getattr(py_value, 'clr_object', py_value)
