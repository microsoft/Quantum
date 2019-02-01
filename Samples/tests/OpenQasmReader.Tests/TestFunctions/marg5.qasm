// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// OpenQASM 2.0 sample file
// Generated as QASM 1.0 from LIQUi|> on 6/30/16, manually converted to OpenQASM 2.0 on 9/13/18
// Description: Margolus gate implementation for input state = (0,1,0,1) 

OPENQASM 2.0;

include "qelib1.inc";

qreg q[5];
creg c[3];

x q[2];
x q[4];
s q[2];
h q[2];
t q[2];
h q[2];
sdg q[2];
cx q[3], q[2];
s q[2];
h q[2];
t q[2];
h q[2];
sdg q[2];
cx q[4], q[2];
s q[2];
h q[2];
tdg q[2];
h q[2];
sdg q[2];
cx q[3], q[2];
s q[2];
h q[2];
tdg q[2];
h q[2];
sdg q[2];
measure q[2] -> c[0];
measure q[3] -> c[1];
measure q[4] -> c[2];
