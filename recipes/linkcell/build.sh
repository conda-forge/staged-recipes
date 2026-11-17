#!/usr/bin/env bash
# Build the linkcell v0.4.2 shared library.
set -euxo pipefail

# Native conda rust still exports CARGO_BUILD_TARGET. v0.4.2 copies
# artifacts from cargo-target/<profile>, which is the layout cargo uses
# when that variable is unset. A cross build keeps the triple.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  unset CARGO_BUILD_TARGET
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

if [[ -z "${MESON_ARGS:-}" ]]; then
  MESON_ARGS="-Dbuildtype=release --prefix=${PREFIX} -Dlibdir=lib"
fi

# Word-splitting of MESON_ARGS is the compiler activation contract.
# shellcheck disable=SC2086
meson setup build ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Ddefault_library=shared \
  -Dwith_tests=false \
  -Dwith_examples=false \
  -Dwith_gpulite=disabled

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
PY
