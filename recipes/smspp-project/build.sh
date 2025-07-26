#!/bin/bash

mkdir build
cd build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    ..
cmake --build . --config Release -j ${CPU_COUNT}
cmake --install . --config Release --prefix "$PREFIX"
