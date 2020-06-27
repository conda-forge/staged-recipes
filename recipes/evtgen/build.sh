#!/usr/bin/env bash

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DEVTGEN_HEPMC3=ON \
    -DEVTGEN_PYTHIA=ON \
    -DEVTGEN_PHOTOS=OFF \
    -DEVTGEN_TAUOLA=OFF \
    ../R0*/

cmake --build . --target install "-j${CPU_COUNT}"
