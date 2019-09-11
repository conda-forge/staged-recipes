#!/bin/sh

set -e

CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"

if test `uname` = "Darwin"
then
  LDFLAGS="-lOsi ${LDFLAGS}"
fi

COIN_SKIP_PROJECTS="Sample" ./configure --prefix="${PREFIX}" \
  --with-coinutils-lib="$(pkg-config --libs coinutils)" \
  --with-coinutils-incdir="${PREFIX}/include/coin/" \
  --with-osi-lib="$(pkg-config --libs osi)" \
  --with-osi-incdir="${PREFIX}/include/coin/" \
  --with-clp-lib="$(pkg-config --libs clp)" \
  --with-clp-incdir="${PREFIX}/include/coin/" \
  --with-cgl-lib="$(pkg-config --libs cgl)" \
  --with-cgl-incdir="${PREFIX}/include/coin/" \
  --with-vol-lib="$(pkg-config --libs vol)" \
  --with-vol-incdir="${PREFIX}/include/coin/" \
  || { cat config.log; exit 1; }
make -j ${CPU_COUNT}
make install
