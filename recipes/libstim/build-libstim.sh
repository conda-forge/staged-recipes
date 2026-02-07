#!/bin/bash
set -ex

# Use _build to avoid conflict with Stim's BUILD directory (case-insensitive on macOS)
cmake ${CMAKE_ARGS} -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -B _build \
    .

cmake --build _build --target libstim

# Manual install - cmake --install tries to install the stim executable too
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/include"
cp _build/out/libstim.a "${PREFIX}/lib/"
cp src/stim.h "${PREFIX}/include/"
