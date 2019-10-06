#!/bin/bash
mkdir build
cd build
cmake -D Python_ADDITIONAL_VERSIONS=${PY_VER} -D Boost_USE_STATIC_LIBS=OFF -D PYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_VER}m -D PYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_VER}m${SHLIB_EXT} -D CMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j${NUM_CPUS} VERBOSE=1
cp -r python/atomicrex ${PREFIX}/lib/python${PY_VER}/site-packages/atomicrex/
cp atomicrex ${PREFIX}/bin
