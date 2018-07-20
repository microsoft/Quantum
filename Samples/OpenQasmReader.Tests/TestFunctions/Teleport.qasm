// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.\
//
// Standard quantum teleportation example
OPENQASM 2.0;
qreg q[3];
creg c[3];
U(0.7,0.8,0.9) q[0];
h q[1];
cx q[1],q[2];
cx q[0],q[1];
h q[0];
measure q[0] -> c[0];
measure q[1] -> c[1];
if(c[0]==1) z q[2];
if(c[1]==1) x q[2];
measure q[2] -> c[2];