#!/bin/bash

set -ex

# Remove vendored submodules - we use conda-forge packages instead
rm -rf 3rdparty/dmlc-core
rm -rf 3rdparty/dlpack

# Build the C++ library
mkdir -p build
cd build
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DUSE_CUDA=OFF \
    -DBUILD_EXAMPLES=OFF \
    ..
make -j${CPU_COUNT}

# Note: C++ tests (cpptest) have linking issues in v0.6.0,
# so we skip them and rely on Python import tests instead

cd ..

# Install the Python bindings
cd python
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
