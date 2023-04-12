#!/usr/bin/env bash
# build script for conda package

set -e
set -x

#rm -rf build && mkdir build && cd build && LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH \
#PKG_CONFIG_PATH=$CONDA_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH \
#LDFLAGS="$LDFLAGS -L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib" \
ls -la
echo $CC
echo $CXX
mkdir build && cd build
cmake \
      -DPKG_CONFIG_EXECUTABLE=$CONDA_PREFIX/bin/pkg-config \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make -j${nproc} && \
make install
