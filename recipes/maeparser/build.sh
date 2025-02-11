#!/bin/bash

set -ex

cmake ${CMAKE_ARGS} \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DPython3_EXECUTABLE="$PYTHON" .

cmake --build . --config Release
cmake --install .
