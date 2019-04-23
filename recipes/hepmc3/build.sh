#!/usr/bin/env bash
# Enable bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

mkdir -p build
cd build

# ROOTIO is currently off, this could be added after ROOT adds a root-base formula

cmake -LAH \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=${CMAKE_PLATFORM_FLAGS[@]+"${CMAKE_PLATFORM_FLAGS[@]}"} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DHEPMC3_ENABLE_ROOTIO=OFF \
    ../source

make -j${CPU_COUNT}
make install
