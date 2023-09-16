#!/bin/sh

rm -rf build
mkdir build
cd build

# BLA_PREFER_PKGCONFIG is used to avoid accidentally linking with Accelerate.framework
# on macOS
cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DBLA_PREFER_PKGCONFIG:BOOL=ON

cmake --build . --config Release
cmake --build . --config Release --target install
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release
fi
