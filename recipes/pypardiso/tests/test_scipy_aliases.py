import pytest
import numpy as np
import scipy.sparse as sp
from scipy.sparse.linalg import spsolve as scipyspsolve
from scipy.sparse.linalg import factorized as scipyfactorized
from pypardiso.scipy_aliases import pypardiso_solver, spsolve, factorized

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


def test_basic_spsolve_vector():
    ps.remove_stored_factorization()
    ps.free_memory()
    A, b = create_test_A_b_rand()
    xpp = spsolve(A, b)
    xscipy = scipyspsolve(A, b)
    np.testing.assert_array_almost_equal(xpp, xscipy)


def test_basic_spsolve_matrix():
    ps.remove_stored_factorization()
    ps.free_memory()
    A, b = create_test_A_b_rand(matrix=True)
    xpp = spsolve(A, b)
    xscipy = scipyspsolve(A, b)
    np.testing.assert_array_almost_equal(xpp, xscipy)


def test_basic_factorized():
    ps.remove_stored_factorization()
    ps.free_memory()
    A, b = create_test_A_b_rand()
    ppfact = factorized(A)
    xpp = ppfact(b)
    scipyfact = scipyfactorized(A)
    xscipy = scipyfact(b)
    np.testing.assert_array_almost_equal(xpp, xscipy)


def test_factorized_modified_A():
    ps.remove_stored_factorization()
    ps.free_memory()
    assert ps.factorized_A.shape == (0, 0)
    A, b = create_test_A_b_small()
    Afact = factorized(A)
    x1 = Afact(b)
    A[4, 0] = 27
    x2 = spsolve(A, b)
    assert not np.allclose(x1, x2)
    assert ps.factorized_A[4, 0] == 27
    x3 = Afact(b)
    np.testing.assert_array_equal(x1, x3)
    assert ps.phase == 33


def test_factorized_csc_matrix():
    ps.remove_stored_factorization()
    ps.free_memory()
    A, b = create_test_A_b_rand()
    Afact_csr = factorized(A)
    Afact_csc = factorized(A.tocsc())
    assert sp.isspmatrix_csr(Afact_csc.args[0])
    x1 = Afact_csr(b)
    x2 = Afact_csc(b)
    np.testing.assert_array_equal(x1, x2)


def test_spsolve_csc_matrix():
    ps.remove_stored_factorization()
    ps.free_memory()
    A, b = create_test_A_b_rand()
    x_csc = spsolve(A.tocsc(), b)
    assert sp.isspmatrix_csr(ps.factorized_A)
    x_csr = spsolve(A, b)
    np.testing.assert_array_equal(x_csr, x_csc)
