#!/bin/bash

set -euxo pipefail

# Let us set the C++ Standard
sed -i '/CMAKE_CXX_STANDARD/d' CMakeLists.txt

export CXXFLAGS="-DPROTOBUF_USE_DLLS=1 ${CXXFLAGS}"
cmake $CMAKE_ARGS \
    -DPROTOBUF_USE_DLLS=ON \
    -DBUILD_STATIC_LIB=OFF \
    -DCMAKE_CXX_STANDARD=17 \
    -DBUILD_TESTS=OFF \
    -GNinja \
    -B build
cmake --build build
cmake --install build
