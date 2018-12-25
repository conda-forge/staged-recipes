#!/bin/bash

mkdir build
cd build

export BUILD_TYPE="Release"

cmake .. -G "${CMAKE_GENERATOR}" \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"

cmake --build . --config "${BUILD_TYPE}" --target install

cmake .. -G "${CMAKE_GENERATOR}" \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"

cmake --build . --config "${BUILD_TYPE}" --target install
