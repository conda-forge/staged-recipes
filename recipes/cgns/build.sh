#! /usr/bin/env bash

_build_shared=ON
if [[ `uname -s` == 'Darwin' ]]; then
    export MACOSX_DEPLOYMENT_TARGET=""
    _build_shared=OFF
fi

mkdir _build && cd _build
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCGNS_BUILD_SHARED=$_build_shared \
    -DCGNS_USE_SHARED=ON \
    -DCGNS_ENABLE_FORTRAN=ON \
    -DFORTRAN_NAMING="LOWERCASE_" \
    -DCGNS_ENABLE_TESTS=ON \
    -DCGNS_ENABLE_LFS=ON \
    -DCMAKE_C_FLAGS:STRING=-D_LARGEFILE64_SOURCE \
    -DCGNS_ENABLE_HDF5=ON \
    -DHDF5_LIBRARY=$PREFIX/lib/libhdf5$SHLIB_EXT \
    -DHDF5_INCLUDE_PATH=$PREFIX/include \
    -DHDF5_NEED_SZIP=OFF \
    -DHDF5_NEED_ZLIB=ON \
    -DZLIB_LIBRARY=$PREFIX/lib/libz$SHLIB_EXT

sed -i.orig 's@^c@!c@' src/cgnslib_f.h

make -j$CPU_COUNT
if [[ `uname -s` == 'Linux' ]]; then
    ctest
fi
make install
