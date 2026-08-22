import numpy as np

import cnchash
from cnchash import available_backends, get_backend_info, run_hash

print("cnchash", cnchash.__version__)
print("backends:", available_backends())
print("info:", get_backend_info())

rng = np.random.default_rng(0)
nsta = 20
az = rng.uniform(5.0, 355.0, nsta)
the = rng.uniform(30.0, 90.0, nsta)
pol = np.where(rng.random(nsta) < 0.5, 1, -1).astype(np.int32)
qual = (rng.random(nsta) < 0.2).astype(np.int32)

out = run_hash(az, the, pol, qual, backend="fortran", nmc=10)
assert out is not None
print("smoke event ok:", out)
