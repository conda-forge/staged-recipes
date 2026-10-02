"""Prepare the v8 build environment for the conda-forge lightpanda build.

Points gn's clang_base_path at the conda build prefix (clangdev + gcc_impl
live there and can run on any CF image) instead of the chromium-bundled
prebuilt toolchain, and bridges the compiler-rt runtime layout gap: the v8
build expects lib/clang/<ver>/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a
while conda's clangdev ships lib/clang/<ver>/lib/linux/libclang_rt.builtins-<arch>.a.
"""

import glob
import os
import shutil
import sys

prefix = sys.prefix
print("diagnostics: sys.executable =", sys.executable)
print("diagnostics: prefix =", prefix)

# 1. point gn's clang_base_path at the build env (clangdev lives here)
p = "deps/v8/build.zig"
s = open(p).read()
s = s.replace("@V8_CLANG_BASE_PATH@", prefix)
assert "@V8_CLANG_BASE_PATH@" not in s, "placeholder was not substituted"
open(p, "w").write(s)

# 2. bridge the compiler-rt runtime layout
bridged = 0
for ver_dir in glob.glob(os.path.join(prefix, "lib", "clang", "*")):
    expected = os.path.join(ver_dir, "lib", "x86_64-unknown-linux-gnu")
    os.makedirs(expected, exist_ok=True)
    for src in glob.glob(os.path.join(ver_dir, "lib", "*", "libclang_rt.*.a")):
        base = os.path.basename(src)
        dst = os.path.join(expected, base)
        if not os.path.exists(dst):
            shutil.copy(src, dst)
            bridged += 1
        # also provide the unsuffixed builtins name the build expects
        if "builtins-" in base:
            unsuffixed = base.replace("builtins-x86_64", "builtins").replace(
                "builtins-aarch64", "builtins"
            )
            dst2 = os.path.join(expected, unsuffixed)
            if not os.path.exists(dst2):
                shutil.copy(src, dst2)
                bridged += 1
print("compiler-rt runtime bridged:", bridged, "files")
