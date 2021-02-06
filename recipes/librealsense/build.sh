#!/bin/sh

mkdir build && cd build

cmake -GNinja \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=ON \
      -DENABLE_CCACHE=OFF \
      -DBUILD_WITH_OPENMP=OFF \
      -DFORCE_RSUSB_BACKEND=ON \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_UNIT_TESTS=OFF \
      $SRC_DIR

cmake --build . --config Release 
cmake --install . --config Release 
