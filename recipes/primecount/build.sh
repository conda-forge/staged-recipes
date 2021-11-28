#!/bin/bash

cmake ${CMAKE_ARGS} \
    -DBUILD_STATIC_LIBS=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTS=ON \
    -DBUILD_LIBPRIMESIEVE=OFF \
    .

make install -j${CPU_COUNT}

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" || "${CMAKE_CROSSCOMPILE_EMULATOR:-}" != "" ]]; then
  ctest -j${CPU_COUNT} --output-on-failure
fi
