#!/bin/sh

cmake ${CMAKE_ARGS} -LAH -G "Ninja" \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  .
cmake --build . --target install --parallel ${CPU_COUNT}

if test "$CONDA_BUILD_CROSS_COMPILATION" != "1"
then
  cmake --build . --target tests --parallel ${CPU_COUNT}
  ctest -E "large|stress" --output-on-failure -j${CPU_COUNT} --timeout 1000
fi
