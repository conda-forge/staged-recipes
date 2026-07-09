#!/usr/bin/env bash
set -euxo pipefail

export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS:-} -I${PREFIX}/include"

# MESON_ARGS already provides prefix and libdir; do not pass them again.
meson setup builddir \
  ${MESON_ARGS} \
  -Ddefault_library=shared \
  -Dbuild_tests=false \
  -Dbuild_exe=false \
  -Dwith_netcdf=true \
  -Dbuild_shared_lib=true

meson compile -C builddir -j "${CPU_COUNT:-2}"
meson install -C builddir

mkdir -p "${PREFIX}/include"
cp -a flowy "${PREFIX}/include/"

mkdir -p "${PREFIX}/lib/pkgconfig"
{
  echo "prefix=${PREFIX}"
  echo 'libdir=${prefix}/lib'
  echo 'includedir=${prefix}/include'
  echo 'Name: flowy'
  echo 'Description: Probabilistic lava emplacement library'
  echo 'Version: 1.0.0'
  echo 'Requires: pdf_cpplib fmt'
  echo 'Libs: -L${libdir} -lflowy'
  echo 'Cflags: -I${includedir}'
} > "${PREFIX}/lib/pkgconfig/flowy.pc"
