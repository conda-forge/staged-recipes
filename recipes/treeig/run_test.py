"""Exercise installed CPU attribution, weighted endpoints, and optional CUDA."""
import importlib.abc
import sys


class BlockCUDA(importlib.abc.MetaPathFinder):
    def find_spec(self, fullname, path=None, target=None):
        if fullname == "numba.cuda" or fullname.startswith("numba.cuda."):
            raise ImportError("CUDA is deliberately unavailable in this test")


sys.meta_path.insert(0, BlockCUDA())

import numpy as np
from sklearn.tree import DecisionTreeRegressor
from treeig import TreeIG, GPUTreeIG, __version__

assert __version__ == "0.2.0"
X = np.array([[0.0], [0.25], [0.75], [1.0]])
model = DecisionTreeRegressor(max_depth=1, random_state=0).fit(X, [0, 0, 2, 2])
threshold = model.tree_.threshold[0]
baselines = np.array([[threshold], [0.0], [1.0]])
weights = np.array([0.2, 0.3, 0.5])
data = np.array([[threshold], [0.0], [1.0]])
ig = TreeIG(model, baseline=baselines, baseline_weights=weights)
result = ig.explain(data)
expected = model.predict(data) - weights @ model.predict(baselines)
np.testing.assert_allclose(result.values[:, 0], expected, atol=1e-12, rtol=0)
np.testing.assert_allclose(result.completeness_error, 0, atol=1e-12, rtol=0)
assert "treeig.cuda_backend" not in sys.modules
assert "numba.cuda" not in sys.modules
try:
    GPUTreeIG(model, baseline=baselines)
except ImportError as exc:
    assert "treeig[cuda]" in str(exc)
else:
    raise AssertionError("GPUTreeIG did not request optional CUDA support")
print("Weighted CPU attribution and boundary ownership passed without CUDA.")
