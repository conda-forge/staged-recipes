#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_PYTHON_INTERFACE=OFF \
      -DCOAL_HAS_QHULL=ON \
      -DBUILD_TESTING=OFF

ninja
ninja install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/coal/coalTargets.cmake
  rm $PREFIX/lib/cmake/coal/coalTargets.cmake.back
fi
