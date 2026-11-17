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
if [[ -n "${LIBRARY_INC:-}" && -d "${LIBRARY_INC}" ]]; then
  incdir="${LIBRARY_INC}"
else
  incdir="${PREFIX}/include"
fi
install -m 644 include/linkcell_gpu.h include/linkcell_gpu.hpp "${incdir}/"

# The cargo target installs a static archive next to the shared library.
# Consumers link the shared library. On Windows the static archive uses
# the import-library name, so -llinkcell keeps the DLL import library.
if [[ -n "${LIBRARY_LIB:-}" && -d "${LIBRARY_LIB}" ]]; then
  libdir="${LIBRARY_LIB}"
else
  libdir="${PREFIX}/lib"
fi
if [[ -f "${libdir}/linkcell.dll.lib" ]]; then
  rm -f "${libdir}/linkcell.lib"
  mv "${libdir}/linkcell.dll.lib" "${libdir}/linkcell.lib"
fi
rm -f "${libdir}/liblinkcell.a"
