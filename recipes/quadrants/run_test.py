import platform
import sys
from pathlib import Path

import quadrants as qd


if sys.platform.startswith("linux"):
    package_root = Path(qd.__file__).parent
    if platform.machine() == "x86_64":
        # with_cuda() reports runtime driver availability, so verify the
        # generated backend bitcode without requiring CI to have an NVIDIA GPU.
        assert (package_root / "_lib/runtime/runtime_cuda.bc").is_file()
    # This binding is only exported when the Vulkan backend is compiled.
    # with_vulkan() also probes runtime device availability, which CPU CI lacks.
    assert hasattr(qd._lib.core, "set_vulkan_visible_device")
elif sys.platform == "darwin":
    assert qd._lib.core.with_metal()


@qd.kernel
def fill_array(values: qd.types.NDArray[qd.i32, 1]) -> None:
    for i in range(4):
        values[i] = i + 1


def main() -> None:
    qd.init(arch=qd.cpu)
    try:
        values = qd.ndarray(qd.int32, (4,))
        fill_array(values)
        assert values.to_numpy().tolist() == [1, 2, 3, 4]
    finally:
        qd.reset()


if __name__ == "__main__":
    main()
