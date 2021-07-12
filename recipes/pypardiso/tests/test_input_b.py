import pytest
import numpy as np
import scipy.sparse as sp
from scipy.sparse import SparseEfficiencyWarning
from pypardiso.pardiso_wrapper import PyPardisoWarning
from pypardiso.scipy_aliases import pypardiso_solver

ps = pypardiso_solver


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


def test_input_b_sparse():
    A, b = create_test_A_b_rand()
    bsparse = sp.csr_matrix(b)
    with pytest.warns(SparseEfficiencyWarning):
        x = ps.solve(A, bsparse)
        np.testing.assert_array_almost_equal(A * x, b)


def test_input_b_shape():
    A, b = create_test_A_b_rand()
    x_array = ps.solve(A, b)
    assert x_array.shape == b.shape
    x_vector = ps.solve(A, b.squeeze())
    assert x_vector.shape == b.squeeze().shape
    np.testing.assert_array_equal(x_array.squeeze(), x_vector)


def test_input_b_dtypes():
    A, b = create_test_A_b_rand()
    for dt in [np.float16, np.float32, np.int16, np.int32, np.int64]:
        bdt = b.astype(dt)
        with pytest.warns(PyPardisoWarning):
            basic_solve(A, bdt)

    for dt in [
        np.complex64,
        np.complex128,
        np.complex128,
        np.uint16,
        np.uint32,
        np.uint64,
    ]:
        bdt = b.astype(dt)
        with pytest.raises(TypeError):
            basic_solve(A, bdt)


def test_input_b_fortran_order():
    A, b = create_test_A_b_rand(matrix=True)
    x = ps.solve(A, b)
    xfort = ps.solve(A, np.asfortranarray(b))
    np.testing.assert_array_equal(x, xfort)


def test_input_b_wrong_shape():
    A, b = create_test_A_b_rand()
    b = np.append(b, 1)
    with pytest.raises(ValueError):
        basic_solve(A, b)
