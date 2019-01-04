// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// OpenQASM 2.0 sample file
// Generated as QASM 1.0 from LIQUi|> on 8/15/16, manually converted to OpenQASM 2.0 on 9/13/18
// Description: 5 qubit code encoder for logical |1> input state

OPENQASM 2.0;

include "qelib1.inc";

qreg q[5];
creg c[3];

x q[4];
h q[3];
cx q[4], q[2];
cx q[1], q[2];
h q[4];
h q[2];
h q[1];
cx q[1], q[2];
h q[2];
h q[1];
cx q[1], q[2];
cx q[4], q[2];
cx q[4], q[2];
h q[2];
h q[4];
cx q[4], q[2];
h q[2];
h q[4];
cx q[4], q[2];
cx q[3], q[2];
cx q[1], q[2];
h q[2];
h q[1];
cx q[1], q[2];
h q[2];
h q[1];
cx q[1], q[2];
cx q[1], q[2];
cx q[0], q[2];
h q[1];
h q[2];
h q[0];
cx q[0], q[2];
h q[2];
h q[0];
cx q[0], q[2];
cx q[3], q[2];
measure q[0];
cx q[4], q[2];
h q[3];
h q[2];
h q[4];
cx q[4], q[2];
h q[2];
h q[4];
cx q[4], q[2];
cx q[3], q[2];
cx q[4], q[2];
measure q[3];
h q[2];
h q[4];
cx q[4], q[2];
h q[2];
h q[4];
cx q[4], q[2];
cx q[1], q[2];
measure q[4] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];
