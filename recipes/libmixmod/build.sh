#!/bin/sh

cmake -LAH -G "Ninja" ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_UNITY_BUILD=ON \
  -B build .

cmake --build build --target install --parallel ${CPU_COUNT}
if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest --test-dir build --output-on-failure -j${CPU_COUNT}
fi
