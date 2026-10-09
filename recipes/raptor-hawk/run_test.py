# The README example: build a kernel and its reverse-mode twin for the host,
# run both, check the values.
import pathlib
import tempfile

import numpy as np

import hawk
from hawk import Kernel, Mutable, Scalar, Vector
from hawk.diff import vjp
from hawk.math import dot


@hawk.kernel
def energy(v: Vector[3], out: Mutable[Scalar]):
    out = 0.5 * dot(v, v)


energy_vjp = Kernel("energy_vjp", vjp(energy, wrt=("v",)))
work = pathlib.Path(tempfile.mkdtemp())
hawk.build([energy, energy_vjp], work, targets=("host",))

v = np.array([[1.0, 2.0, 3.0, 4.0], [0.0, 1.0, 0.0, 1.0], [0.0, 0.0, 1.0, 1.0]])
e = np.zeros(4)
hawk.run(hawk.load(work, "energy"), v=v, out=e)
np.testing.assert_allclose(e, [0.5, 2.5, 5.0, 9.0])

bar_v = np.zeros((3, 4))
hawk.run(hawk.load(work, "energy_vjp"), v=v, bar_out=np.ones(4), bar_v=bar_v)
np.testing.assert_allclose(bar_v, v)
print("hawk host route OK")
