import random
import numpy as np

import ambit

print("before")
ambit.initialize()
print("initialized")

def build_and_fill2(name, dims):
    print(f"fill {dims=}")
    T = ambit.Tensor.build(ambit.TensorType.CoreTensor, name, dims)
    print(T)
    N = [[0 for x in range(dims[1])] for x in range(dims[0])]
    print(N)

    data = np.asarray(T)
    print(data)
    for r in range(dims[0]):
        for c in range(dims[1]):
            value = random.random()
            print(r, c, value)

            data[r, c] = value
            N[r][c] = value
            print("   ", data[r, c], N[r][c])

    print(T)
    print(N)
    return [T, N]


ni = 9
nj = 6
nk = 7

[aA, nA] = build_and_fill2("A", [ni, nk])
[aB, nB] = build_and_fill2("B", [nk, nj])
[aC, nC] = build_and_fill2("C", [ni, nj])

aC["ij"] += aA["ik"] * aB["kj"]

for i in range(ni):
    for j in range(nj):
        for k in range(nk):
            nC[i][j] += nA[i][k] * nB[k][j]

print(np.array(aC))
print(np.array(nC))

assert np.allclose(aC, nC, atol=1.e-12)
print("asserted")
ambit.finalize()
print("finalized")
