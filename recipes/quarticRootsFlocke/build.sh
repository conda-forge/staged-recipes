#!/usr/bin/bash
echo "CMAKE_ARGS: ${CMAKE_ARGS}"
echo "PREFIX: ${PREFIX}"

cmake \
  -B build \
  -S . \
  -G Ninja \
  -DENABLE_CTEST=ON \
  -DBUILD_EXECUTABLE=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DVERSION=1.0.0 \
  ${CMAKE_ARGS}

cmake --build build
cmake --install build
cmake --build build --target test
