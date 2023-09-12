#! /bin/bash

set -e
set -x

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_SHARED_LIBS=ON \
    -DUHDM_BUILD_TESTS=OFF \
    -DUHDM_USE_HOST_CAPNP=ON \
    -DCMAKE_MACOSX_RPATH=1 \
    -DCMAKE_INSTALL_RPATH=$PREFIX/lib \
    -DPYTHON_EXECUTABLE="$PYTHON" \
    -DPython3_EXECUTABLE="$PYTHON" \
    -DCMAKE_FIND_FRAMEWORK=NEVER \
    -DCMAKE_FIND_APPBUNDLE=NEVER

cmake --build build --config Release
cmake --install build --config Release
