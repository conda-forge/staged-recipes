#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

mkdir build
cd build
cmake -LAH .. \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release

make -j${CPU_COUNT}
make install
