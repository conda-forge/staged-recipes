#!/bin/sh

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DMUJOCO_BUILD_TESTS:BOOL=ON \
      -DMUJOCO_BUILD_EXAMPLES:BOOL=OFF \
      -DMUJOCO_ENABLE_AVX:BOOL=OFF \
      -DMUJOCO_ENABLE_AVX_INTRINSICS:BOOL=OFF \
      -DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=ON \
      ..

cmake --build . --config Release

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release
fi

cmake --build . --config Release --target install
