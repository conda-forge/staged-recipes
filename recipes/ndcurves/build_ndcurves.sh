#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_DOCUMENTATION=OFF \
      -DBUILD_PYTHON_INTERFACE=OFF \
      -DGENERATE_PYTHON_STUBS=OFF \
      -DCURVES_WITH_PINOCCHIO_SUPPORT=ON \
      -DBUILD_TESTING=OFF

ninja
ninja install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/ndcurves/ndcurvesTargets.cmake
  rm $PREFIX/lib/cmake/ndcurves/ndcurvesTargets.cmake.back
fi

