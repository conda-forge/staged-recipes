#!/usr/bin/env bash
set -euxo pipefail

# MESON_ARGS already sets -Dbuildtype=release, --prefix, and -Dlibdir.
meson setup builddir \
  ${MESON_ARGS} \
  -Dwith_rpc=true \
  -Dwith_fortran_pots=enabled \
  -Dwith_eigen=true \
  -Dpure_lib=false \
  -Dwith_cache=false \
  -Dwith_tests=false \
  -Dwith_examples=false

meson compile -C builddir -j "${CPU_COUNT:-2}"
meson install -C builddir

# The installed headers and the shared library are the consumer surface.
smoke_bin="${SRC_DIR}/rgpot-link-smoke"
"${CXX}" -std=c++20 "${RECIPE_DIR}/link_smoke.cpp" -o "${smoke_bin}" \
  $(pkg-config --cflags --libs rgpot)
if [ "$(uname)" = "Darwin" ]; then
  DYLD_LIBRARY_PATH="${PREFIX}/lib${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}" \
    "${smoke_bin}"
else
  LD_LIBRARY_PATH="${PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" \
    "${smoke_bin}"
fi
