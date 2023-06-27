#!/bin/bash

set -e

if [[ $target_platform =~ .*osx.* ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_XHOST=OFF"
fi

mkdir -p build/
cd build/

cmake .. \
  ${CMARKE_ARGS} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release

# build
make -j${CPU_COUNT}

# install
make install
