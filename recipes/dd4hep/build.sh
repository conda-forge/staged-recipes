#!/usr/bin/env bash

mkdir build && cd build

cmake -DDD4HEP_USE_GEANT4=OFF \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DROOT_DIR="${PREFIX}" \
    -DPython_FIND_STRATEGY=LOCATION \
    -DDD4HEP_BUILD_PACKAGES="DDRec DDDetectors DDCond DDAlign DDG4 DDEve UtilityApps" \
    ../source

cmake --build . --target install -j${CPU_COUNT}
