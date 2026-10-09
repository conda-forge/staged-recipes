# The README example on the CPU route: NumPy arrays in, OpenMP threads out.
import numpy as np

import eagle
import hawk
from hawk import Mutable, Param, Scalar, Terminated


@hawk.kernel
def oscillator(omega: Scalar, t_end: Param, dt: Param, terminated: Terminated,
               x: Mutable[Scalar], v: Mutable[Scalar], t: Mutable[Scalar]):
    x0, v0 = x, v
    x = x0 + dt * v0
    v = v0 - dt * omega * omega * x0
    t += dt
    terminated = t >= t_end


n = 1000
result = eagle.simulate(
    oscillator,
    omega=np.linspace(1.0, 3.0, n), t_end=1.0, dt=1e-3,
    x=np.ones(n), v=np.zeros(n), t=np.zeros(n),
    max_steps=10_000,
)
assert "finished" in str(result.status), result.status
np.testing.assert_allclose(result.x[0], 0.54057281, rtol=1e-6)
print("eagle CPU route OK", result.x[:3])
