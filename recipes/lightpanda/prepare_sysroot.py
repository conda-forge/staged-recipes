"""Prepare the v8 build environment for the conda-forge lightpanda build.

Points gn's clang_base_path at the conda build prefix, so v8 compiles and
links with the conda-forge clangdev + gcc_impl toolchain (which can run on
any CF image) instead of the chromium-bundled prebuilt toolchain. The
placeholder lives in the vendored zig-v8-fork build.zig and is substituted
here.

sys.prefix is used instead of os.environ["BUILD_PREFIX"] because the CF
script runner passes a literal "$BUILD_PREFIX" as the env value.
"""

import os
import sys

prefix = sys.prefix
print("diagnostics: sys.executable =", sys.executable)
print("diagnostics: sys.prefix =", prefix)
print("diagnostics: env BUILD_PREFIX =", os.environ.get("BUILD_PREFIX"))
p = "deps/v8/build.zig"
s = open(p).read()
s = s.replace("@V8_CLANG_BASE_PATH@", prefix)
assert "@V8_CLANG_BASE_PATH@" not in s, "placeholder was not substituted"
open(p, "w").write(s)
print("v8 toolchain set to:", prefix)
