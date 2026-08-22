#!/bin/sh

mkdir build
cd build

cmake \
  ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DPython3_EXECUTABLE=${PYTHON} \
  -DKDDockWidgets_QT6=false \
  -DKDDockWidgets_STATIC=false \
  -DKDDockWidgets_EXAMPLES=false \
  -DKDDockWidgets_PYTHON_BINDINGS=true \
  -DCMAKE_BUILD_TYPE=Release \
  ..
make install -j${CPU_COUNT}

