#!/bin/sh

echo Building python

cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -BUILD_DEPS=OFF \
      -DUSE_SCIP=OFF \
      -S. \
      -Bbuild \
      -DBUILD_SAMPLES=OFF \
      -DBUILD_EXAMPLES=OFF \
      -BUILD_PYTHON=ON \
      -DPython3_EXECUTABLE="$PYTHON"

cmake --build build --target python_package -j${CPU_COUNT}
