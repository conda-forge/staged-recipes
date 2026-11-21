# Smoke test: value, gradient and Hessian of small expressions through the
# C bindings. The dense quad_form path goes through CBLAS, so this also
# checks that BLAS is linked and callable.
import numpy as np

from sparsediffpy import _sparsediffengine as de


def check(expr, u, value, grad, hess):
    prob = de.make_problem(expr, [], False)
    de.problem_init_jacobian_coo(prob)
    de.problem_init_hessian_coo_lower_triangular(prob)
    np.testing.assert_allclose(de.problem_objective_forward(prob, u), value)
    np.testing.assert_allclose(de.problem_gradient(prob), grad)
    rows, cols, _ = de.get_problem_hessian_sparsity_coo(prob)
    vals = de.problem_eval_hessian_vals_coo(prob, 1.0, np.zeros(0))
    H = np.zeros((u.size, u.size))
    H[rows, cols] = vals
    np.testing.assert_allclose(np.tril(H), np.tril(hess))


u = np.array([1.0, -2.0, 0.5])

x = de.make_variable(3, 1, 0, 3)
check(de.make_sum(de.make_exp(x), -1), u, np.exp(u).sum(), np.exp(u), np.diag(np.exp(u)))

P = np.array([[2.0, 1.0, 0.0], [1.0, 3.0, 0.0], [0.0, 0.0, 4.0]])
x = de.make_variable(3, 1, 0, 3)
check(de.make_quad_form(None, x, "dense", P.flatten(order="F"), 3), u, u @ P @ u, 2 * P @ u, 2 * P)

print("sparsediffpy smoke test passed")
