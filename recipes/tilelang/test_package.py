"""Packaging checks for tilelang.

Usage: python test_package.py <version> <cpu|cuda>
"""

import importlib.metadata
import importlib.util
import os
import sys

version, flavor = sys.argv[1], sys.argv[2]
assert flavor in ("cpu", "cuda"), flavor

# No local version label (e.g. `0.1.14+cu130.gitabcdef`) in the metadata.
dist_version = importlib.metadata.version("tilelang")
assert dist_version == version, f"{dist_version!r} != {version!r}"

root = os.path.dirname(importlib.util.find_spec("tilelang").origin)
third_party = os.path.join(root, "3rdparty")

# Defensive checks on vendored code, so that anything newly vendored by a
# future release is noticed (and its license added) instead of silently shipped.
# Only the TileLang fork of TVM is expected; CUTLASS comes from `cutlass`.
entries = sorted(os.listdir(third_party))
assert entries == ["tvm"], f"unexpected vendored components: {entries}"
tvm_entries = sorted(os.listdir(os.path.join(third_party, "tvm")))
expected_tvm = ["include", "python", "src", "version.py"]
assert tvm_entries == expected_tvm, f"unexpected vendored TVM contents: {tvm_entries}"

# Native libraries: libtvm_ffi and libz3 must come from their own packages.
libs = sorted(f for f in os.listdir(os.path.join(root, "lib")) if not f.startswith("."))
print("tilelang/lib:", libs)
for unwanted in ("tvm_ffi", "z3"):
    assert not any(unwanted in f for f in libs), f"{unwanted} is bundled: {libs}"
if sys.platform.startswith("linux"):
    for lib in ("libtilelang.so", "libtvm_compiler.so", "libtvm_runtime.so"):
        assert lib in libs, f"{lib} missing: {libs}"
    if flavor == "cuda":
        for lib in ("libstub_cuda.so", "libstub_cudart.so", "libstub_nvrtc.so"):
            assert lib in libs, f"{lib} missing: {libs}"

import tilelang  # noqa: E402
import tilelang.env  # noqa: E402

print("tilelang", tilelang.__version__)
assert tilelang.__version__ == version, tilelang.__version__

if flavor == "cuda":
    import tilelang.cuda  # noqa: F401

    # The JIT must find CUTLASS/CuTe in the prefix now that it is not vendored.
    inc = tilelang.env.CUTLASS_INCLUDE_DIR
    print("CUTLASS_INCLUDE_DIR:", inc)
    assert inc and os.path.samefile(inc, os.path.join(sys.prefix, "include")), inc
    for header in ("cutlass/cutlass.h", "cute/tensor.hpp"):
        assert os.path.isfile(os.path.join(inc, header)), header

    # Lower a small kernel down to CUDA C++ source; this exercises the compiled
    # TileLang/TVM passes and the CUDA codegen, without needing a GPU or nvcc.
    import tilelang.language as T

    @T.prim_func
    def add_one(A: T.Tensor((1024,), "float32"), B: T.Tensor((1024,), "float32")):
        with T.Kernel(8, threads=128) as bx:
            for i in T.Parallel(128):
                B[bx * 128 + i] = A[bx * 128 + i] + 1.0

    from tilelang import tvm

    cuda_target = {"kind": "cuda", "arch": "sm_80"}
    # Some passes look up the current target, so lower inside a target context.
    with tvm.target.Target(cuda_target):
        artifact = tilelang.lower(add_one, target=cuda_target)
    assert "__global__" in artifact.kernel_source, artifact.kernel_source
    print(artifact.kernel_source)
