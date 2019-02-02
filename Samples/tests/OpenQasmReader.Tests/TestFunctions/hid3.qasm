// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// OpenQASM 2.0 sample file
// Generated as QASM 1.0 from LIQUi|> on 6/30/16, manually converted to OpenQASM 2.0 on 9/13/18
// Description: Hidden shift problem on inner product bent function for instance = (0,0,1,1) 

OPENQASM 2.0;

include "qelib1.inc";

qreg q[5];
creg c[4];

h q[1];
h q[2];
h q[3];
h q[4];
x q[1];
x q[2];
h q[2];
cx q[1], q[2];
h q[2];
x q[1];
x q[2];
cx q[4], q[2];
h q[2];
h q[4];
cx q[4], q[2];
h q[2];
h q[4];
cx q[4], q[2];
h q[2];
cx q[3], q[2];
h q[2];
h q[1];
h q[2];
h q[3];
h q[4];
h q[2];
cx q[3], q[2];
h q[2];
cx q[4], q[2];
h q[2];
h q[4];
cx q[4], q[2];
h q[2];
h q[4];
cx q[4], q[2];
h q[2];
cx q[1], q[2];
h q[2];
h q[1];
h q[2];
h q[3];
h q[4];
measure q[1] -> c[0];
measure q[2] -> c[1];
measure q[3] -> c[2];
measure q[4] -> c[3];
