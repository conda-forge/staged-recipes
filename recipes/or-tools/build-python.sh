#!/bin/sh

cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_DEPS=OFF \
      -DUSE_SCIP=OFF \
      -S. \
      -Bbuild \
      -DBUILD_SAMPLES=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_PYTHON=ON \
      -DPython3_EXECUTABLE="$PYTHON"

cmake --build build -j${CPU_COUNT}

echo Install begins here

${PYTHON} -m pip install --no-index --find-links=build/python/dist ortools -vv
