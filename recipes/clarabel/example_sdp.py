import clarabel
import numpy as np
from scipy import sparse


n = 3
nvec = int(n*(n+1)/2)

# Define problem data
P = sparse.csc_matrix((nvec, nvec))
P = P.tocsc()

q = np.array([1., 0., 1., 0., 0., 1.])
sqrt2 = np.sqrt(2.)

A = sparse.csc_matrix(
    [[-1., 0., 0., 0., 0., 0.],
     [0., -sqrt2, 0., 0., 0., 0.],
     [0., 0., -1., 0., 0., 0.],
     [0., 0., 0., -sqrt2, 0., 0.],
     [0., 0., 0., 0., -sqrt2, 0.],
     [0., 0., 0., 0., 0., -1.],
     [1., 4., 3., 8., 10., 6.]])

b = np.append(np.zeros(nvec), 1.)

cones = [clarabel.PSDTriangleConeT(n),
         clarabel.ZeroConeT(1)]

settings = clarabel.DefaultSettings()

solver = clarabel.DefaultSolver(P, q, A, b, cones, settings)
solution = solver.solve()
assert solution.status == clarabel.SolverStatus.Solved
