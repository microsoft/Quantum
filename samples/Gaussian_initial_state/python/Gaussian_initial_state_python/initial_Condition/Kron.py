import numpy as np
N = 3
SWAP = np.array([[1, 0, 0, 0], 
                [0, 0, 1, 0], 
                [0, 1, 0, 0],
                [0, 0, 0, 1]])
I = np.identity(2)
I_inv = np.linalg.inv(I)
global perm
if N == 2:
    perm = SWAP
if N == 3:
    t0 = np.kron(I, SWAP)
    print('t0')
    print(t0)
    t1 = np.kron(SWAP, I)  
     
    perm = np.matmul(t1, t0)
    perm = np.matmul(perm, t1)
if N > 3:
    n0 = N - 2
    l = I
    for j in range(n0 - 1):
        l = np.kron(l, I) 
    t0 = np.kron(l, SWAP)
    print(t0)
    n1 = N - 1 - 2
    l = I
    for j in range(n1 - 1):
        l = np.kron(l, I)
    t1 = np.kron(l, SWAP)
    t1 = np.kron(t1, I)
    print(t1)    
    perm = np.matmul(t1, t0)
    perm = np.matmul(perm, t1)
print(perm)
        




'''print(A)              
print(I_inv)
t1 = np.kron(A, I)
t0 = np.kron(I, A)
#t1 = np.kron(t1, I)
print(t1)
print(t0)
temp = np.matmul(t0, t1)
perm = np.matmul(t1, temp)
print(perm)'''

