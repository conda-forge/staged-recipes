#!/bin/sh

mkdir build
cd build

cmake .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON \
      -DBUILD_SHARED_LIBS=ON \
      -DOMPL_BUILD_DEMOS=OFF \
      -DOMPL_BUILD_TESTS=OFF \
      -DOMPL_BUILD_PYTESTS=OFF \
      -DOMPL_REGISTRATION=OFF

cmake --build . --config Release --target install
