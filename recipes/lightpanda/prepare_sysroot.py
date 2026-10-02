"""Prepare the v8 build environment for the conda-forge lightpanda build.

Runs from the browser source root (the rattler-build work dir):
1. Substitutes the @V8_SYSROOT_*@ placeholders in the vendored zig-v8-fork
   build.zig with the absolute conda sysroot paths (the fork forwards them
   as environment variables to the autoninja step).
2. Copies the glibc development headers from sysroot_linux-64 into the
   vendored chromium clang's builtin resource include dirs — siso (chromium's
   build executor) does not propagate the environment to compile subprocesses,
   so command-line/env-based include paths never reach clang.
"""

import glob
import os
import shutil

prefix = os.environ["BUILD_PREFIX"]
sysroot = os.path.join(prefix, "x86_64-conda_sysroot")

# 1. fork build.zig placeholders -> absolute sysroot paths
p = "deps/v8/build.zig"
s = open(p).read()
s = s.replace("@V8_SYSROOT_INCLUDE@", sysroot + "/include")
s = s.replace("@V8_SYSROOT_LIBRARY_PATH@", sysroot + "/lib")
open(p, "w").write(s)

# 2. glibc dev headers -> vendored clang resource include dirs
n = 0
pattern = ".lp-cache/v8-*/third_party/llvm-build/Release+Asserts/lib/clang/*/include"
for d in glob.glob(pattern):
    for src in glob.glob(sysroot + "/include/**/*.h", recursive=True):
        rel = os.path.relpath(src, sysroot + "/include")
        dst = os.path.join(d, rel)
        if os.path.exists(dst):
            continue  # keep clang builtins (stddef.h, stdarg.h, ...)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy(src, dst)
        n += 1

print("sysroot paths substituted; glibc headers copied into clang resource dirs:", n)
assert n > 0, "no glibc headers were copied — is sysroot_linux-64 installed?"
