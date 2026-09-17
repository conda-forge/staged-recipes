import apprentice
import numpy as np

rng = np.random.default_rng(0)
X = rng.uniform(-1, 1, size=(200, 2))  # shape (n_points, n_params)
X_test = rng.uniform(-1, 1, size=(20, 2))


def polynomial(x):
    return 1.0 + 2.0 * x[:, 0] - 3.0 * x[:, 1] + 0.5 * x[:, 0] * x[:, 1]


def rational(x):
    return polynomial(x) / (3.0 + x[:, 0] + x[:, 1])


# Exact recovery is expected as the models contain the true functions
poly_approx = apprentice.PolynomialApproximation(X, polynomial(X), order=2)
np.testing.assert_allclose(
    [poly_approx(x) for x in X_test], polynomial(X_test), rtol=1e-8, atol=1e-10
)

rational_approx = apprentice.RationalApproximation(X, rational(X), order=(2, 1))
np.testing.assert_allclose(
    [rational_approx(x) for x in X_test], rational(X_test), rtol=1e-6, atol=1e-8
)
