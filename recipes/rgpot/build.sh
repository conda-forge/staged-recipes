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
