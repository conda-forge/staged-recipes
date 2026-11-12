"""Exercise installed numerical APIs without network access or optional extras."""
import os

os.environ["HTFA_AUTO_INSTALL"] = "0"

import numpy as np
from threadpoolctl import threadpool_limits

import htfa
from htfa.stats import reconstruction_statistics

assert htfa.__version__ == "0.1.0"

with threadpool_limits(limits=1):
    xs, rs, _ = htfa.make_htfa_data(
        n_subjects=2, grid_shape=(8, 8), K=2, n_samples=15, random_state=1
    )
    subjects = [htfa.Subject(x, r) for x, r in zip(xs, rs)]
    for kernel, components in [("rbf", 1), ("laplace", 2)]:
        model = htfa.HTFA(
            K=2, kernel=kernel, n_components=components,
            max_global_iter=1, random_state=0, backend="cpu", n_jobs=1,
        ).fit(xs, rs)
        result = htfa.HTFAResults(model, subjects)
        for i, x in enumerate(xs):
            reconstructed = result.reconstruct(i)
            assert reconstructed.shape == x.shape
            assert np.isfinite(reconstructed).all()
        score = reconstruction_statistics(result)
        assert np.isfinite([score.r2, score.aic, score.bic]).all()
        assert score.n_observations == sum(x.size for x in xs)
print("HTFA single-component and mixture fit/reconstruction checks passed")
