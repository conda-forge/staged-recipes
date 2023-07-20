#!/usr/bin/env bash
set -e -x

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON \
    ..

make -k -j${CPU_COUNT}
ctest --rerun-faild --output-on-failure
make install