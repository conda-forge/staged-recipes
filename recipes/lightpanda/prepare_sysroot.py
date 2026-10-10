"""Prepare the v8 build environment for the conda-forge lightpanda build.

1. Points gn's clang_base_path at the conda build prefix (clangdev lives
   there) so v8 compiles with a toolchain that can run on any CF image
   instead of the chromium-bundled prebuilt one.
2. Copies the glibc dev headers into the vendored chromium clang's builtin
   resource include dirs (siso does not propagate the environment to compile
   subprocesses, so include paths must be physical files).
3. Collects the glibc CRT objects and libgcc into a single directory and
   injects it as -B/-L into the v8 compiler config (the clang driver resolves
   libc_nonshared.a / Scrt1.o / crtbeginS.o from those search paths when
   linking v8's internal executables — the CF container ships the glibc
   runtime but no development files).
"""

import glob
import os
import shutil
import sys

prefix = sys.prefix
real_prefix = os.path.realpath(prefix)
print("diagnostics: sys.executable =", sys.executable)
print("diagnostics: prefix =", prefix, "| realpath =", real_prefix)

# 1. point gn's clang_base_path at the build env (clangdev lives here)
p = "deps/v8/build.zig"
s = open(p).read()
s = s.replace("@V8_CLANG_BASE_PATH@", prefix)
assert "@V8_CLANG_BASE_PATH@" not in s, "placeholder was not substituted"
open(p, "w").write(s)

# 2. glibc dev headers -> vendored chromium clang resource include dirs
n = 0
for d in glob.glob(".lp-cache/v8-*/third_party/llvm-build/Release+Asserts/lib/clang/*/include"):
    for base in (prefix, real_prefix):
        inc = base + "/x86_64-conda-linux-gnu/sysroot/usr/include"
        if not os.path.isdir(inc):
            continue
        for src in glob.glob(inc + "/**/*.h", recursive=True):
            rel = os.path.relpath(src, inc)
            dst = os.path.join(d, rel)
            if os.path.exists(dst):
                continue  # keep clang builtins (stddef.h, stdarg.h, ...)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy(src, dst)
            n += 1
print("glibc headers copied into clang resource dirs:", n)

# 3. collect the link-time objects (glibc CRT + gcc runtime) into one dir
link_dir = os.path.abspath(".lp-cache/gnu-link-objects")
os.makedirs(link_dir, exist_ok=True)
collected = 0
search_globs = [
    prefix + "/x86_64-conda-linux-gnu/sysroot/usr/lib64/*",
    real_prefix + "/x86_64-conda-linux-gnu/sysroot/usr/lib64/*",
    prefix + "/lib/gcc/*/*/*",
    real_prefix + "/lib/gcc/*/*/*",
    prefix + "/lib64/gcc/*/*/*",
    real_prefix + "/lib64/gcc/*/*/*",
]
wanted_names = (
    "libc_nonshared.a",
    "Scrt1.o",
    "crt1.o",
    "crti.o",
    "crtn.o",
    "Mcrt1.o",
    "crtbegin.o",
    "crtend.o",
    "crtbeginS.o",
    "crtendS.o",
    "libgcc.a",
    "libgcc_s.so",
    "libgcc_s.so.1",
)
for g in search_globs:
    for src in glob.glob(g):
        if os.path.basename(src) in wanted_names and os.path.isfile(src):
            dst = os.path.join(link_dir, os.path.basename(src))
            if not os.path.exists(dst):
                shutil.copy(src, dst)
                collected += 1
print("link objects collected:", collected)

# 4. inject that directory into the v8 compiler config ldflags
gn_file = ".lp-cache/v8-*/build/config/compiler/BUILD.gn"
gn_file = glob.glob(gn_file)[0]
s = open(gn_file).read()
anchor = """  rustenv = []
  rustflags = []
  ldflags = []
  defines = []
  configs = []"""
if "__V8_LINK_DIR__" not in s:
    if anchor not in s:
        raise SystemExit("no se encontró el anchor del config('compiler')")
    s = s.replace(
        anchor,
        """  rustenv = []
  rustflags = []
  ldflags = [ "-B__V8_LINK_DIR__/", "-L__V8_LINK_DIR__/" ]
  defines = []
  configs = []""",
        1,
    )
s = s.replace("__V8_LINK_DIR__", link_dir)
open(gn_file, "w").write(s)
print("v8 compiler config patched with -B/-L:", link_dir)

# 5. bridge the compiler-rt runtime into the path the v8 build.gn computes:
#    <build_env>/lib/clang/<ver>/lib/x86_64-unknown-linux-gnu/ — where
#    <build_env> is the sibling "build_env" dir of this work dir. conda's
#    compiler-rt installs the legacy layout (lib/linux/, suffixed names),
#    while clang 19+ GN configs expect the triple subdir with unsuffixed
#    names, so we place both.
expected_root = os.path.join(os.path.dirname(os.getcwd()), "build_env", "lib", "clang")
bridged = 0
for src in glob.glob(
    os.path.join(sys.prefix, "lib", "clang", "*", "lib", "*", "libclang_rt.*.a")
):
    ver = src.split(os.sep + "lib" + os.sep + "clang" + os.sep)[1].split(os.sep)[0]
    dst = os.path.join(expected_root, ver, "lib", "x86_64-unknown-linux-gnu", os.path.basename(src))
    if not os.path.exists(dst):
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy(src, dst)
        bridged += 1
    base = os.path.basename(src)
    if "builtins-" in base:
        unsuffixed = base.replace("builtins-x86_64", "builtins").replace(
            "builtins-aarch64", "builtins"
        )
        dst2 = os.path.join(expected_root, ver, "lib", "x86_64-unknown-linux-gnu", unsuffixed)
        if not os.path.exists(dst2):
            shutil.copy(src, dst2)
            bridged += 1
print("compiler-rt runtime bridged into build_env:", bridged, "files")
