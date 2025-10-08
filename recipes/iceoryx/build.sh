#!/bin/bash

mkdir build
cd build
cmake ${CMAKE_ARGS} -DBUILD_SHARED_LIBS=ON ../iceoryx_meta
make -j${CPU_COUNT}
make install
