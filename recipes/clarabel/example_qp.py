import clarabel
import numpy as np
from scipy import sparse

# Define problem data
P = sparse.csc_matrix([[3., 0.], [0., 2.]])
P = sparse.triu(P).tocsc()

q = np.array([-1., -4.])

A = sparse.csc_matrix(
    [[1., -2.],        # <-- LHS of equality constraint (lower bound)
     [1.,  0.],        # <-- LHS of inequality constraint (upper bound)
     [0.,  1.],        # <-- LHS of inequality constraint (upper bound)
     [-1.,  0.],       # <-- LHS of inequality constraint (lower bound)
     [0., -1.]])       # <-- LHS of inequality constraint (lower bound)

b = np.array([0., 1., 1., 1., 1.])

cones = [clarabel.ZeroConeT(1), clarabel.NonnegativeConeT(4)]
settings = clarabel.DefaultSettings()

solver = clarabel.DefaultSolver(P, q, A, b, cones, settings)
solution = solver.solve()
assert solution.status == clarabel.SolverStatus.Solved
