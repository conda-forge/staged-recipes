#!/bin/bash
mkdir build
cd build
cmake -D PYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_VER}m -D PYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_VER}m${SHLIB_EXT} -D CMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j${NUM_CPUS}
cp -r python/atomicrex ${PREFIX}/lib/python${PY_VER}/site-packages/atomicrex/
cp atomicrex ${PREFIX}/bin
