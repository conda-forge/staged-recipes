#!/bin/sh

# Copy qdldl files to the submodule directory
cp -r qdldl/. osqp/lin_sys/direct/qdldl/qdldl_sources

cd osqp

mkdir build && cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=ON \
      ..

make -j${CPU_COUNT}
make install