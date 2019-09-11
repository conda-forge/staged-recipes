#!/bin/sh

set -e

COIN_SKIP_PROJECTS="Sample" ./configure --prefix="${PREFIX}" \
  --with-blas-lib="-lblas" \
  --with-lapack-lib="-llapack" \
  --with-glpk-lib="-lglpk" \
  || { cat config.log; exit 1; }
make -j${CPU_COUNT}
make install
