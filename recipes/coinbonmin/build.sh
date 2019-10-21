
set -e

CXXFLAGS="-I${PREFIX}/include/asl ${CXXFLAGS}"

COIN_SKIP_PROJECTS="Sample" ./configure --prefix="${PREFIX}" \
  --with-coinutils-lib="$(pkg-config --libs coinutils)" \
  --with-coinutils-incdir="${PREFIX}/include/coin/" \
  --with-osi-lib="$(pkg-config --libs osi)" \
  --with-osi-incdir="${PREFIX}/include/coin/" \
  --with-clp-lib="$(pkg-config --libs clp)" \
  --with-clp-incdir="${PREFIX}/include/coin/" \
  --with-cgl-lib="$(pkg-config --libs cgl)" \
  --with-cgl-incdir="${PREFIX}/include/coin/" \
  --with-cbc-lib="$(pkg-config --libs cbc)" \
  --with-cbc-incdir="${PREFIX}/include/coin/" \
  --with-ipopt-lib="$(pkg-config --libs ipopt)" \
  --with-ipopt-incdir="${PREFIX}/include/coin/" \
  || { cat config.log; exit 1; }
make -j ${CPU_COUNT}
make install
