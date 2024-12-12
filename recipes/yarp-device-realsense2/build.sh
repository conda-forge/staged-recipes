#!/bin/sh

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      ..

cmake --build . --config Release

if [[ ("${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "") ]]; then
  ctest --output-on-failure  -C Release
fi

cmake --build . --config Release --target install
