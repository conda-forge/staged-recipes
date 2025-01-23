#!/bin/sh

rm -rf build
mkdir build

cd build

cmake ${CMAKE_ARGS} .. \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DPYTHON_EXECUTABLE=$PYTHON \
      -DBUILD_DOCUMENTATION=OFF \
      -DBUILD_PYTHON_INTERFACE=ON \
      -DGENERATE_PYTHON_STUBS=ON \
      -DCURVES_WITH_PINOCCHIO_SUPPORT=ON \
      -DBUILD_TESTING=OFF

ninja
ninja install

