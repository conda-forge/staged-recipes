#!/bin/bash
mkdir build
cd build
cmake -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DTD_BUILD_SHARED_LIBS=ON \
  -DTD_ENABLE_TESTS=ON \
  -G Ninja ..
cmake --build . --target install -j${CPU_COUNT}
cd ..
ls -l