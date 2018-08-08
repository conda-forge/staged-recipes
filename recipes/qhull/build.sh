#!/bin/sh

CMAKE_GENERATOR="Unix Makefiles"

cmake -G "$CMAKE_GENERATOR" \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} 

make -j${CPU_COUNT}
make install
