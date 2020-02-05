#!/bin/bash

# NOTE: This assumes the following environment variables have been set.
#       - `${PREFIX}`

mkdir -p build
pushd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -DTARGET_NATIVE_ARCH:BOOL=OFF \
    -S .. \
    -B .

cmake \
    --build . \
    --config Release \
    --target install
