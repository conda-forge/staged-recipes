"""Prepare the v8 build environment for the conda-forge lightpanda build.

1. Points gn's clang_base_path at the conda build prefix (clangdev lives
   there) so v8 compiles with a toolchain that can run on any CF image
   instead of the chromium-bundled prebuilt one.
2. Copies the glibc dev headers into the vendored chromium clang's builtin
   resource include dirs (siso does not propagate the environment to compile
   subprocesses, so include paths must be physical files).
3. Places the glibc CRT objects and libgcc into /usr/lib64, where the clang
   driver looks for them when linking v8's internal executables — the CF
   container ships the glibc runtime but no development files.
"""

import glob
import os
import shutil
import sys

prefix = sys.prefix
print("diagnostics: sys.executable =", sys.executable)
print("diagnostics: prefix =", prefix)
print("diagnostics: realpath =", os.path.realpath(prefix))
print("diagnostics: env BUILD_PREFIX =", os.environ.get("BUILD_PREFIX"))

# 1. point gn's clang_base_path at the build env (clangdev lives here)
p = "deps/v8/build.zig"
s = open(p).read()
s = s.replace("@V8_CLANG_BASE_PATH@", prefix)
assert "@V8_CLANG_BASE_PATH@" not in s, "placeholder was not substituted"
open(p, "w").write(s)

# 2. locate the sysroot (glibc headers + CRT objects); resolve through the
#    literal prefix dir if it is a symlink to the real build env
candidates = [
    prefix + "/x86_64-conda-linux-gnu/sysroot",
    os.path.realpath(prefix) + "/x86_64-conda-linux-gnu/sysroot",
]
sysroot = next((c for c in candidates if os.path.isdir(c + "/usr/lib64")), None)
if sysroot is None:
    hits = glob.glob(prefix + "/**/libc_nonshared.a", recursive=True) + glob.glob(
        os.path.realpath(prefix) + "/**/libc_nonshared.a", recursive=True
    )
    sysroot = os.path.dirname(os.path.dirname(hits[0])) if hits else None
print("sysroot:", sysroot)
assert sysroot, "glibc sysroot with libc_nonshared.a not found"

# 3. glibc dev headers -> vendored chromium clang resource include dirs
n = 0
for d in glob.glob(".lp-cache/v8-*/third_party/llvm-build/Release+Asserts/lib/clang/*/include"):
    for src in glob.glob(sysroot + "/usr/include/**/*.h", recursive=True):
        rel = os.path.relpath(src, sysroot + "/usr/include")
        dst = os.path.join(d, rel)
        if os.path.exists(dst):
            continue  # keep clang builtins (stddef.h, stdarg.h, ...)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy(src, dst)
        n += 1
print("glibc headers copied into clang resource dirs:", n)

# 4. create a GCC installation dir inside the vendored chromium clang prefix:
#    the clang driver's GCC detection scans <clang-prefix>/lib/gcc/<triple>/<ver>/
#    for the CRT objects and libgcc when linking v8's internal executables
#    (mksnapshot, torque, ...) — the CF container lacks them entirely.
gcc_root = glob.glob(".lp-cache/v8-*/third_party/llvm-build/Release+Asserts")[0]
gcc_dir = gcc_root + "/lib/gcc/x86_64-conda-linux-gnu/14"
os.makedirs(gcc_dir, exist_ok=True)
placed = 0
for f in ("crt1.o", "Scrt1.o", "crti.o", "crtn.o", "Mcrt1.o", "libc_nonshared.a"):
    src = os.path.join(sysroot, "usr/lib64", f)
    if os.path.exists(src) and not os.path.exists(os.path.join(gcc_dir, f)):
        shutil.copy(src, gcc_dir)
        placed += 1
for src in glob.glob(prefix + "/lib/gcc/*/*/crt*.o") + glob.glob(
    prefix + "/lib/gcc/*/*/libgcc*.a"
) + glob.glob(prefix + "/lib64/gcc/*/*/crt*.o") + glob.glob(
    prefix + "/lib64/gcc/*/*/libgcc*.a"
):
    dst = os.path.join(gcc_dir, os.path.basename(src))
    if not os.path.exists(dst):
        shutil.copy(src, dst)
        placed += 1
print("crt/libgcc placed in the clang GCC-installation dir:", placed)