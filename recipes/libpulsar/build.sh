#!/bin/bash

set -euxo pipefail

# Let us set the C++ Standard
sed -i '/CMAKE_CXX_STANDARD/d' CMakeLists.txt

export CXXFLAGS="-DPROTOBUF_USE_DLLS=1 ${CXXFLAGS}"

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake $CMAKE_ARGS \
    -DPROTOBUF_USE_DLLS=ON \
    -DBUILD_STATIC_LIB=OFF \
    -DCMAKE_CXX_STANDARD=17 \
    -DBUILD_TESTS=OFF \
    -GNinja \
    -B build
cmake --build build
cmake --install build
