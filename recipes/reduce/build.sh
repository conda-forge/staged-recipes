#!/bin/bash
if [ -d "build" ]; then
  rm -rf build
fi
mkdir -p build
cd build
cmake ${SRC_DIR} ${CMAKE_ARGS}
make
make install

