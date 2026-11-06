import numpy as np
from scipy import sparse

import moreau

P = sparse.diags([1.0, 1.0], format="csr")
q = np.array([2.0, 1.0])
A = sparse.csr_matrix([[1.0, 1.0], [1.0, 0.0], [0.0, 1.0]])
b = np.array([1.0, 0.7, 0.7])
cones = moreau.Cones(num_zero_cones=1, num_nonneg_cones=2)

solver = moreau.Solver(P, q, A, b, cones)
solution = solver.solve()

assert solver.info.status == moreau.SolverStatus.Solved, solver.info.status
print(solution.x, solver.info.obj_val)
