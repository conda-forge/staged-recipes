#! /bin/bash

set -e
set -x

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake -B build_shared \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_MACOSX_RPATH=1 \
    -DCMAKE_INSTALL_RPATH=$PREFIX/lib

cmake --build build_shared --config Release
cmake --install build_shared --config Release

# prune assets with no control to not build
rm -rf $PREFIX/lib/libgtest*
rm -rf $PREFIX/lib/libgmock*
