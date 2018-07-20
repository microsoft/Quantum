// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
OPENQASM 2.0;

qreg q[6];
creg c[6];
U(0.0,0.0,1.0) q[0];
U(0.0,2.0,1.0) q[1];
U(3.0,2.0,1.0) q[2];
u3(0.0,0.0,5.0) q[3];
u3(0.0,6.0,5.0) q[4];
u3(7.0,6.0,5.0) q[5];
measure q -> c;