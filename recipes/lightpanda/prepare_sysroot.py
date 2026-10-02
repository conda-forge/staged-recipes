"""Prepare the v8 build environment for the conda-forge lightpanda build.

Runs from the browser source root (the rattler-build work dir): substitutes
the @V8_CLANG_BASE_PATH@ placeholder in the vendored zig-v8-fork build.zig
with the conda build prefix, so v8 compiles with the conda-forge clangdev +
gcc_impl toolchain (which can run on any CF image) instead of the
chromium-bundled prebuilt toolchain.
"""

import os

prefix = os.environ["BUILD_PREFIX"]
p = "deps/v8/build.zig"
s = open(p).read()
s = s.replace("@V8_CLANG_BASE_PATH@", prefix)
assert "@V8_CLANG_BASE_PATH@" not in s, "placeholder was not substituted"
open(p, "w").write(s)
print("v8 toolchain set to:", prefix)
