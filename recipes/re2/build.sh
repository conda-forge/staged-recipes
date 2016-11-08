#!/bin/bash
set -e
set -x

mkdir -p build
cd build
cmake -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}" \
      ..
make -j "${CPU_COUNT}"
make -j "${CPU_COUNT}" test
make -j "${CPU_COUNT}" install
