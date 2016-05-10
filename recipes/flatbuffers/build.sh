#!/bin/bash

# C++11 finagling
if [ "$(uname)" == "Darwin" ]; then
  # for Mac OSX
  export CC=clang
  export CXX=clang++
  export MACOSX_VERSION_MIN="10.7"
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export LDFLAGS="${LDFLAGS} -stdlib=libc++ -std=c++11"
  export LINKFLAGS="${LDFLAGS}"
fi

cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DFLATBUFFERS_BUILD_TESTS=OFF .
make
make install
