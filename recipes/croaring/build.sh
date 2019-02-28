#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [ `uname` == "Darwin" ]; then
    export CXXFLAGS="-D__APPLE_USE_RFC_3542 -D_XOPEN_SOURCE -D_DARWIN_C_SOURCE $CXXFLAGS"
fi

mkdir -p build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    ${SRC_DIR}

make install
make test