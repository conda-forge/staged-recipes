#!/bin/bash

set -ex

# Build the C++ library
mkdir -p build
cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DUSE_CUDA=OFF \
    -DBUILD_EXAMPLES=OFF
make -j${CPU_COUNT}
cd ..

# Install the Python bindings
cd python
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
