// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// OpenQASM 2.0 sample file
// Generated as QASM 1.0 from LIQUi|> on 8/14/16, manually converted to OpenQASM 2.0 on 9/13/18
// Description: Bernstein Vazirani problem for instance = (0,0,1,1) 

OPENQASM 2.0;

include "qelib1.inc";

qreg q[5];
creg c[4];

x q[2];
h q[0];
h q[1];
h q[2];
h q[3];
h q[4];
cx q[0], q[2];
cx q[1], q[2];
h q[0];
h q[1];
h q[3];
h q[4];
measure q[0];
measure q[1];
measure q[3];
measure q[4];
