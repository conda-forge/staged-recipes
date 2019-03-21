#!/bin/sh

mkdir build && cd build

# needs qt5 for imageio
cmake -LAH -G"$CMAKE_GENERATOR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCGAL_INSTALL_LIB_DIR=lib \
  -DWITH_CGAL_ImageIO=OFF \
  -DWITH_CGAL_Qt5=OFF \
  ..
make install -j${CPU_COUNT}

DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib ctest --output-on-failure -j${CPU_COUNT}
