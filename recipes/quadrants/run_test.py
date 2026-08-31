import platform
import sys
from pathlib import Path

import quadrants as qd


package_root = Path(qd.__file__).parent
machine = platform.machine().lower()

if sys.platform != "darwin":
    # The availability helpers probe for physical devices. Verify the packaged
    # backend payloads instead, since conda-forge CI has no GPUs.
    assert (package_root / "_lib/runtime/runtime_cuda.bc").is_file()
    assert (package_root / "_lib/runtime/slim_libdevice.10.bc").is_file()
    # This binding is only exported when the Vulkan backend is compiled.
    assert hasattr(qd._lib.core, "set_vulkan_visible_device")
    if sys.platform.startswith("linux") and machine in {"amd64", "x86_64"}:
        assert (package_root / "_lib/runtime/runtime_amdgpu.bc").is_file()
        assert any((package_root / "_lib/runtime_rocm70").glob("*.bc"))
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
