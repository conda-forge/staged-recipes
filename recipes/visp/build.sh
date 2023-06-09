#!/bin/sh

set -ex

if [[ "$target_platform" == linux* ]]; then
    export OGRE_DIR="${PREFIX}/lib/OGRE/cmake"
elif [[ "$target_platform" == osx* ]]; then
    export OGRE_DIR="${PREFIX}/cmake"
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTS=ON

# build
cmake --build . --parallel ${CPU_COUNT}

# install 
cmake --build . --parallel ${CPU_COUNT} --target install

# test
ctest --parallel ${CPU_COUNT}