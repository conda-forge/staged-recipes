#!/bin/bash

mkdir -p build
cd build
cmake ..                             \
    ${CMAKE_ARGS}                    \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DASP_DEPS_DIR=${PREFIX}         \
    -DCORE_ASP_ONLY=ON               \
    -DCMAKE_VERBOSE_MAKEFILE=ON
make -j${CPU_COUNT} install
