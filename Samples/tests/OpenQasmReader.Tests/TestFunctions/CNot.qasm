// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
OPENQASM 2.0;
include "qelib1.inc";
qreg q[2];
creg c[2];
H q[0]; 
cx q[0],q[1];
measure q -> c;