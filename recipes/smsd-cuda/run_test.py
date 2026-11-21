# SPDX-License-Identifier: Apache-2.0
"""Package/runtime linkage checks; this is not a GPU execution test."""
import ctypes
from importlib.metadata import requires, version
from pathlib import Path
import sys

import smsd
import smsd_cuda

assert version("smsd-cuda") == smsd_cuda.__version__ == smsd_cuda.__smsd_version__ == smsd.__version__
assert version("smsd") == smsd.__version__
assert any(item == f"smsd=={smsd.__version__}" for item in requires("smsd-cuda"))
assert not any(item.startswith("nvidia-cuda-runtime") for item in requires("smsd-cuda"))
library = smsd_cuda._load()
assert library is not None, smsd_cuda._reason

runtime_files = {Path(line.split()[-1]).resolve() for line in Path("/proc/self/maps").read_text().splitlines()
                 if "/libcudart.so" in line}
expected_runtime = (Path(sys.prefix) / "lib/libcudart.so.12").resolve(strict=True)
assert runtime_files == {expected_runtime}, runtime_files
runtime = ctypes.CDLL(str(next(iter(runtime_files))))
runtime.cudaRuntimeGetVersion.argtypes = [ctypes.POINTER(ctypes.c_int)]
runtime.cudaRuntimeGetVersion.restype = ctypes.c_int
runtime_version = ctypes.c_int()
assert runtime.cudaRuntimeGetVersion(ctypes.byref(runtime_version)) == 0
assert 12080 <= runtime_version.value < 13000
print("Exact SMSD versions and conda CUDA runtime linkage checked; GPU execution not tested")
