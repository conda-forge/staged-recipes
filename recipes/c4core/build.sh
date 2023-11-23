#!/bin/bash

# Fetch auxiliary GitHub projects only needed to build c4core (they are not
# shipped with the library!) Note c4core relies on git submodules, but since we
# have downloaded a tarball, we need to fetch these repos manually.
# git clone https://github.com/biojppm/cmake.git --depth 1
# rm -rf src/c4/ext/debugbreak/ && git clone https://github.com/biojppm/debugbreak.git --depth 1 src/c4/ext/debugbreak

cp -r deps/cmake .
cp -r deps/debugbreak ./src/c4/ext

# Configure the build of the library
cd c4core
mkdir build
cd build
cmake -GNinja .. ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release

# Build and install the library in $PREFIX
ninja install
