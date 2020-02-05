#!/bin/bash

# NOTE: This assumes the following environment variables have been set.
#       - `${PREFIX}`
#       - `${SRC_DIR}`
# H/T: https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html

mkdir -p build
pushd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -DTARGET_NATIVE_ARCH:BOOL=OFF \
    -S "${SRC_DIR}/src/fortran" \
    -B .

cmake \
    --build . \
    --config Release \
    --target install
