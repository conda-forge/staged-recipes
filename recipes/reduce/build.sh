#!/bin/bash
if [ -d "build" ]; then
  rm -rf build
fi
mkdir -p build
cd build
cmake ${SRC_DIR} ${CMAKE_ARGS}
make -j${CPU_COUNT}
make install

