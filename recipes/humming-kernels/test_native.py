"""Exercise the packaged native helpers without a GPU or a compiler."""

import os
import subprocess
import sys
import tempfile
from pathlib import Path

import humming
from humming.utils import cubin, jit, nvrtc

package_dir = Path(humming.__file__).parent
sources = {
    "launcher": "launcher",
    "device_info": "device_info.cpp",
    "cubin_patcher": "patch_cubin.cpp",
    "nvrtc_compile": "nvrtc_compile.cpp",
}
for component, source in sources.items():
    artifact = jit.get_precompiled_artifact_path(
        package_dir / "csrc" / source, jit.get_native_artifact_name(component)
    )
    assert artifact is not None, f"Missing or stale precompiled {component}"


# Fail if either helper attempts to compile itself at runtime.
def no_compiler():
    raise AssertionError("A packaged native helper attempted runtime compilation")


jit.get_cpp_compiler = no_compiler

# Use NVIDIA's driver stub only to test loading and operator registration.
# No device calls or GPU execution are performed in this subprocess.
with tempfile.TemporaryDirectory() as directory:
    stub, = Path(sys.prefix).glob("targets/*/lib/stubs/libcuda.so")
    (Path(directory) / "libcuda.so.1").symlink_to(stub)
    environment = os.environ.copy()
    environment["LD_LIBRARY_PATH"] = directory + ":" + environment.get("LD_LIBRARY_PATH", "")
    subprocess.run(
        [sys.executable, "-c", """
from humming.ops.utils import init_humming_launcher
from humming.utils import device, jit

def no_compiler():
    raise AssertionError("A packaged native helper attempted runtime compilation")

jit.get_cpp_compiler = no_compiler
init_humming_launcher()
assert hasattr(device._get_device_info_extension(), "_DeviceInfo")
"""],
        env=environment,
        check=True,
    )

try:
    cubin.patch_cubin_bytes(b"not a cubin", "cvt_e3m4")
except RuntimeError as error:
    assert "rc=3" in str(error), str(error)
else:
    raise AssertionError("The cubin patcher accepted an invalid cubin")

with tempfile.TemporaryDirectory() as directory:
    source = Path(directory) / "smoke.cu"
    output = Path(directory) / "smoke.cubin"
    source.write_text('extern "C" __global__ void smoke(float *x) { x[0] = 1.0f; }\n')
    subprocess.run(
        [
            nvrtc.may_build_nvrtc_compile_binary(),
            "--nvrtc-path", nvrtc.get_nvrtc_library_path(),
            "--input", str(source),
            "--output", str(output),
            "--", "--gpu-architecture=sm_80",
        ],
        check=True,
    )
    assert cubin.get_cubin_kernel_names(output) == ["smoke"]
