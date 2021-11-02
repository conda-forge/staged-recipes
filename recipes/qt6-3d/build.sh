#!/bin/sh

mkdir build && cd build
cmake -LAH ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_FIND_FRAMEWORK=LAST \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  ..
make install -j${CPU_COUNT}

