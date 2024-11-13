#!/bin/sh

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DBUILD_TESTING:BOOL=ON \
      -DBUILD_F2C:BOOL=OFF \
      -DUSE_LTO:BOOL=OFF \
      ..

cmake --build . --config Release

if [[ ("${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "") ]]; then
  ctest --output-on-failure  -C Release
fi

cmake --build . --config Release --target install
