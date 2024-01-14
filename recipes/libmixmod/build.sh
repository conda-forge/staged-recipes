#!/bin/sh

cmake ${CMAKE_ARGS} -LAH -G "Ninja" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DMIXMOD_BUILD_EXAMPLES=ON \
  -DCMAKE_UNITY_BUILD=ON \
  .
cmake --build . --target install --parallel ${CPU_COUNT}

if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  ctest --output-on-failure -j${CPU_COUNT} --timeout 1000
fi
