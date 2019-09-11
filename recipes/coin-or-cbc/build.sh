#!/usr/bin/env bash
set -e

UNAME="$(uname)"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"

# Use only 1 thread with OpenBLAS to avoid timeouts on CIs.
# This should have no other affect on the build. A user
# should still be able to set this (or not) to a different
# value at run-time to get the expected amount of parallelism.
export OPENBLAS_NUM_THREADS=1

COIN_SKIP_PROJECTS="Sample" ./configure --prefix="${PREFIX}" --exec-prefix="${PREFIX}" \
  --with-coinutils-lib="$(pkg-config --libs coinutils)" \
  --with-coinutils-incdir="${PREFIX}/include/coin/" \
  --with-osi-lib="$(pkg-config --libs osi)" \
  --with-osi-incdir="${PREFIX}/include/coin/" \
  --with-clp-lib="$(pkg-config --libs clp)" \
  --with-clp-incdir="${PREFIX}/include/coin/" \
  --with-cgl-lib="$(pkg-config --libs cgl)" \
  --with-cgl-incdir="${PREFIX}/include/coin/" \
  --enable-cbc-parallel \
  || { cat config.log; exit 1; }
make -j "${CPU_COUNT}"
if [ "${UNAME}" == "Linux" ]; then
  make test
fi
make install
