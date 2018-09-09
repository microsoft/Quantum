// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.\
//
// Standard quantum teleportation example
OPENQASM 2.0;
qreg q[3];
creg c0[1];
creg c1[1];
creg c2[1];
U(0.7,0.8,0.9) q[0];
h q[1];
cx q[1],q[2];
cx q[0],q[1];
h q[0];
measure q[0] -> c0[0];
measure q[1] -> c1[0];
if(c0==1) z q[2];
if(c1==1) x q[2];
measure q[2] -> c2[0];