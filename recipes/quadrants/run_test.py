import platform
import sys
from pathlib import Path

import quadrants as qd


if sys.platform.startswith("linux"):
    package_root = Path(qd.__file__).parent
    if platform.machine() == "x86_64":
        # CUDA driver libraries are optional at runtime, so verify the packaged
        # backend bitcode instead of requiring CI to have an NVIDIA device.
        assert qd._lib.core.with_cuda()
        assert (package_root / "_lib/runtime/runtime_cuda.bc").is_file()
    # This binding and result require the compiled Vulkan backend and loader.
    assert hasattr(qd._lib.core, "set_vulkan_visible_device")
    assert qd._lib.core.with_vulkan()
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
