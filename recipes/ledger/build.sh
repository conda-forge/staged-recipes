#!/bin/sh
set -ex

cmake . \
  -DUSE_PYTHON=ON \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib
make -j${CPU_COUNT} VERBOSE=1
ctest --output-on-failure -j${CPU_COUNT}
make install -j${CPU_COUNT}
