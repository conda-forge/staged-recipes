#!/bin/bash

set -ex

if [[ $(uname)  == "Linux" ]]; then
    export LDFLAGS="$LDFLAGS -lrt"
fi

cmake ${CMAKE_ARGS} -G Ninja -B _build -DELFIO_BUILD_TESTS=on

cmake --build _build

(cd _build && ctest)

cmake --install _build
