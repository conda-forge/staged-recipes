#!/bin/bash

set -ex

# Manually fetch submodules (tarball doesn't include git submodules)
# dmlc-core submodule
git clone https://github.com/dmlc/dmlc-core.git 3rdparty/dmlc-core
cd 3rdparty/dmlc-core
git checkout d07fb7a443b5db8a89d65a15a024af6a425615a5
cd ../..

# dlpack submodule
git clone https://github.com/dmlc/dlpack.git 3rdparty/dlpack
cd 3rdparty/dlpack
git checkout 5c792cef3aee54ad8b7000111c9dc1797f327b59
cd ../..

# Build the C++ library
mkdir -p build
cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DUSE_CUDA=OFF \
    -DBUILD_EXAMPLES=OFF
make -j${CPU_COUNT}

# Note: C++ tests (cpptest) have linking issues in v0.6.0,
# so we skip them and rely on Python import tests instead

cd ..

# Install the Python bindings
cd python
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
