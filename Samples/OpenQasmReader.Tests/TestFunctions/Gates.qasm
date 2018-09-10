// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
OPENQASM 2.0;
gate majority a,b,c 
{ 
  cx c,b; 
  cx c,a; 
  ccx a,b,c; 
}

qreg q[3];
majority q[0],q[1],q[2]