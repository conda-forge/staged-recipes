#!/usr/bin/env bash
# Build the linkcell v0.6.0 shared library.
set -euxo pipefail

# Native conda rust still exports CARGO_BUILD_TARGET. v0.6.0 copies
# artifacts from cargo-target/<profile>, which is the layout cargo uses
# when that variable is unset. A cross build keeps the triple.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  unset CARGO_BUILD_TARGET
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

if [[ -z "${MESON_ARGS:-}" ]]; then
  MESON_ARGS="-Dbuildtype=release --prefix=${PREFIX} -Dlibdir=lib"
fi

# The fused k-nearest OpenMP region links libgomp on Linux and libomp on
# macOS. Meson and build.rs look for libomp under LIBOMP_PREFIX before
# Homebrew, so the host prefix's llvm-openmp is the runtime that is
# linked, also when cross-compiling to osx-arm64. Windows has no region.
case "${target_platform:?}" in
  linux-*)
    USE_OPENMP=true
    ;;
  osx-*)
    USE_OPENMP=true
    export LIBOMP_PREFIX="${PREFIX}"
    ;;
  *)
    USE_OPENMP=false
    ;;
esac

# Word-splitting of MESON_ARGS is the compiler activation contract.
# shellcheck disable=SC2086
meson setup build ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Ddefault_library=shared \
  -Dwith_tests=false \
  -Dwith_examples=false \
  -Dwith_gpulite=disabled \
  -Duse_openmp="${USE_OPENMP}"

meson compile -C build -j "${CPU_COUNT:-2}"
meson install -C build --no-rebuild

# The device headers are part of the installed API. Without gpulite the
# C++ header's available() is an inline false, so a CPU consumer can
# include it. Meson installs them only when the device library is built.
# Python does the copies: the Windows builder's bash has no GNU install,
# which is what failed the win-64 staged-recipes build.
python - <<'PY'
import os
import shutil
from pathlib import Path

prefix = Path(os.environ["PREFIX"])
inc = Path(os.environ["LIBRARY_INC"]) if os.environ.get("LIBRARY_INC") else prefix / "include"
lib = Path(os.environ["LIBRARY_LIB"]) if os.environ.get("LIBRARY_LIB") else prefix / "lib"
inc.mkdir(parents=True, exist_ok=True)
for name in ("linkcell_gpu.h", "linkcell_gpu.hpp"):
    shutil.copyfile(Path("include") / name, inc / name)
# The cargo target installs a static archive beside the shared library.
# On Windows that archive is linkcell.lib, the same name as the import
# library -llinkcell needs. Keep the import library and drop the archive.
implib = lib / "linkcell.dll.lib"
static_lib = lib / "linkcell.lib"
if implib.is_file():
    if static_lib.is_file():
        static_lib.unlink()
    implib.replace(static_lib)
unix_static = lib / "liblinkcell.a"
if unix_static.is_file():
    unix_static.unlink()
# Meson writes -L<dir> for the directory it found the OpenMP runtime in.
# Under GCC that is the compiler's own lib/gcc directory in the build
# environment, which a consumer does not have; its compiler driver finds
# -lgomp without it. -L entries inside the host prefix stay.
build_prefix = os.environ.get("BUILD_PREFIX")
pc = lib / "pkgconfig" / "linkcell.pc"
if build_prefix and pc.is_file():
    build_root = Path(build_prefix).resolve()

    def outside_build(flag):
        if not flag.startswith("-L") or "${" in flag:
            return True
        target = Path(flag[2:]).resolve()
        return target != build_root and build_root not in target.parents

    lines = []
    for line in pc.read_text().splitlines():
        if line.startswith("Libs"):
            key, _, flags = line.partition(":")
            kept = [flag for flag in flags.split() if outside_build(flag)]
            line = key + ": " + " ".join(kept)
        lines.append(line)
    pc.write_text("\n".join(lines) + "\n")
PY
