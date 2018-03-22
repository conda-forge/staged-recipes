#!/bin/sh
mkdir build && cd build
cmake \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DBUILD_ONLY='s3;core;transfer;config' \
  -DENABLE_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release ..
make -j${CPU_COUNT}
make install
