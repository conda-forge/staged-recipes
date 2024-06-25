#! /bin/bash

set -ex

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

mkdir -p build
cd build

cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_CXX_FLAGS="-Wno-deprecated" \
    -DCMAKE_CXX_STANDARD=11 \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DPython3_EXECUTABLE="$PYTHON" \
    -DHAVE_SSL=ON \
    -DQUICKFIX_EXAMPLES=OFF \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    ..

cmake --build .
cmake --install .
