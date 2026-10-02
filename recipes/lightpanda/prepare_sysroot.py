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

# 4. CRT objects + libgcc -> /usr/lib64 (the clang driver's default search
#    path for linking v8's internal executables; the container lacks them)
lib64 = "/usr/lib64"
os.makedirs(lib64, exist_ok=True)
copied = 0
wanted = (
    "libc_nonshared.a",
    "Scrt1.o",
    "crt1.o",
    "crti.o",
    "crtn.o",
    "Mcrt1.o",
)
for f in wanted:
    src = os.path.join(sysroot, "usr/lib64", f)
    if os.path.exists(src) and not os.path.exists(os.path.join(lib64, f)):
        shutil.copy(src, lib64)
        copied += 1
for gcc_dir in glob.glob(prefix + "/lib/gcc/*/*/") + glob.glob(
    os.path.realpath(prefix) + "/lib/gcc/*/*/"
):
    for f in ("crtbegin.o", "crtend.o", "crtbeginS.o", "crtendS.o", "libgcc.a", "libgcc_s.so"):
        src = os.path.join(gcc_dir, f)
        if os.path.exists(src) and not os.path.exists(os.path.join(lib64, f)):
            shutil.copy(src, lib64)
            copied += 1
print("crt/libgcc files placed in /usr/lib64:", copied)
