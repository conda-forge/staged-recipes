#!/bin/sh

rm -rf build

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DPYTHON_EXECUTABLE=$PYTHON \
      -DBUILD_PYTHON_INTERFACE=ON \
      -DGENERATE_PYTHON_STUBS=ON \
      -DBUILD_EXAMPLES=ON \
      -DBUILD_BENCHMARK=OFF \
      -DBUILD_TESTING=OFF

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install