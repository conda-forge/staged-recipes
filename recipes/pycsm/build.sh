#!/bin/sh
mkdir build && cd build
cmake -D CMAKE_BUILD_TYPE=Release\
      -D CMAKE_INSTALL_PREFIX=$PREFIX\
      -D CMAKE_OSX_DEPLOYMENT_TARGET=10.11\
      $SRC_DIR
cmake --build .
cd python
$PYTHON -m pip install . --no-deps -vv
