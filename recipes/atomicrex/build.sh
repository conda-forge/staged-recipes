#!/bin/bash
export LDFLAGS="$LDFLAGS -lrt"
mkdir build
cd build
cmake -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_VER}m -DPYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_VER}m${SHLIB_EXT} -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make VERBOSE=1
cp -r python/atomicrex ${PREFIX}/lib/python${PY_VER}/site-packages/atomicrex/
cp atomicrex ${PREFIX}/bin
