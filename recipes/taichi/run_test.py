import numpy as np
import taichi as ti


ti.init(arch=ti.cpu, cpu_max_num_threads=1, log_level=ti.ERROR)

n = 8
values = ti.field(dtype=ti.i32, shape=n)


@ti.kernel
def fill_values():
    for i in values:
        values[i] = i * i + 1


fill_values()

expected = np.arange(n, dtype=np.int32) ** 2 + 1
np.testing.assert_array_equal(values.to_numpy(), expected)
