#!/bin/sh

set -ex

if [[ "$target_platform" == linux* ]]; then
    export OGRE_DIR="${PREFIX}/lib/OGRE/cmake"
elif [[ "$target_platform" == osx* ]]; then
    export OGRE_DIR="${PREFIX}/cmake"
fi

# Dealing with modern C++ for Darwin in embedded catch library.
# See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
if [[ $target_platform == osx* ]] ; then
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
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