from pypardiso.scipy_aliases import pypardiso_solver
import numpy as np
import scipy.sparse as sp

ps = pypardiso_solver


def create_test_A_b_small(matrix=False, sort_indices=True):
    """
    --- A ---
    scipy.sparse.csr.csr_matrix, float64
    matrix([[5, 1, 0, 0, 0],
            [0, 6, 2, 0, 0],
            [0, 0, 7, 3, 0],
            [0, 0, 0, 8, 4],
            [0, 0, 0, 0, 9]])
    --- b ---
    np.ndarray, float64
    array([[ 1],
           [ 4],
           [ 7],
           [10],
           [13]])
    or
    array([[ 1,  2,  3],
           [ 4,  5,  6],
           [ 7,  8,  9],
           [10, 11, 12],
           [13, 14, 15]])

    """
    A = sp.spdiags(
        np.arange(10, dtype=np.float64).reshape(2, 5), [1, 0], 5, 5, format="csr"
    )
    if sort_indices:
        A.sort_indices()
    b = np.arange(1, 16, dtype=np.float64).reshape(5, 3)
    if matrix:
        return A, b
    else:
        return A, b[:, [0]]


def create_test_A_b_rand(n=1000, density=0.05, matrix=False):
    np.random.seed(27)
    A = sp.csr_matrix(sp.rand(n, n, density) + sp.eye(n))
    if matrix:
        b = np.random.rand(n, 5)
    else:
        b = np.random.rand(n, 1)

    return A, b


def basic_solve(A, b):
    x = ps.solve(A, b)
    np.testing.assert_array_almost_equal(A * x, b)


def test_bvector_smoketest():
    A, b = create_test_A_b_rand()
    basic_solve(A, b)


def test_bmatrix_smoketest():
    A, b = create_test_A_b_rand(matrix=True)
    basic_solve(A, b)
