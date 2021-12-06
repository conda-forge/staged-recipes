#!/bin/bash

set -ex

cmake ${CMAKE_ARGS} -G Ninja -B _build -DELFIO_BUILD_TESTS=on

cmake --build _build

if [[ $(uname) == "Linux" ]]; then
    # The tests only run on Linux (executables must be ELF files)
    (cd _build && ctest)
fi

cmake --install _build
