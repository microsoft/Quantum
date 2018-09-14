// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
OPENQASM 2.0;
include "qelib1.inc";
qreg q[1];
creg c[1];
H q[0]; 
measure q[0] -> c[1];