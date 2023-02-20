#!/bin/sh
set -ex

mkdir build/
cd build/

if [ "$(uname)" == "Darwin" ]; then
    EXTRA_CMAKE_ARGS="${EXTRA_CMAKE_ARGS} -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
fi

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=ON \
    -DWITH_EXTERNAL_COIN=True \
    -DWITH_EXTERNAL_BACKWARD=True \
    -DWITH_EXTERNAL_PUGIXML=True \
    ${EXTRA_CMAKE_ARGS}

make -j ${CPU_COUNT}
make install
