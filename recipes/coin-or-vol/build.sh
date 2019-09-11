#!/bin/sh

set -e

COIN_SKIP_PROJECTS="Sample" ./configure --prefix="${PREFIX}" \
  --with-coinutils-lib="$(pkg-config --libs coinutils)" \
  --with-coinutils-incdir="${PREFIX}/include/coin/" \
  --with-osi-lib="$(pkg-config --libs osi)" \
  --with-osi-incdir="${PREFIX}/include/coin/" \
  || { cat config.log; exit 1; }
make -j ${CPU_COUNT}
make install
