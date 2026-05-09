import numpy as np
import taichi as ti
from taichi._lib import core as ti_core


assert ti_core.get_version_string() == "1.7.3"
assert ti_core.get_llvm_target_support()

vector = ti.Vector([1, 2, 3])
np.testing.assert_array_equal(vector.to_numpy(), np.array([1, 2, 3]))

matrix = ti.Matrix([[1, 2], [3, 4]])
np.testing.assert_array_equal(matrix.to_numpy(), np.array([[1, 2], [3, 4]]))
