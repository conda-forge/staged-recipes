import numpy as np
import scipy.sparse as sp
from pypardiso import PyPardisoSolver

N = int(1e3)
density = 0.01

# Complex symmetric
A = sp.csr_matrix(sp.rand(N, N, density) + 1j * sp.rand(N, N, density) + sp.eye(N))
A = A + A.transpose()
b = np.random.rand(N, 1) + 1j * np.random.rand(N, 1)

ps = PyPardisoSolver(mtype=3)
x = ps.solve(A, b)
np.testing.assert_array_almost_equal(A * x, b)

# Complex unsymmetric
A = sp.csr_matrix(sp.rand(N, N, density) + 1j * sp.rand(N, N, density) + sp.eye(N))
b = np.random.rand(N, 1) + 1j * np.random.rand(N, 1)

ps = PyPardisoSolver(mtype=13)
x = ps.solve(A, b)
np.testing.assert_array_almost_equal(A * x, b)
