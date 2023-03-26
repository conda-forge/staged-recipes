#!/bin/sh

rm -rf build
mkdir build
cd build

# MSGPACK_CXX20 does not force all consumer libraries to use C++20,
# it just uses C++20 to compile the test suite so all tests are compiled
cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      -DMSGPACK_CXX20:BOOL=ON \
      -DMSGPACK_BUILD_TESTS:BOOL=ON

cmake --build . --config Release
cmake --build . --config Release --target install
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release
fi
