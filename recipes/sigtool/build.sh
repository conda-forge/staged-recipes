#!/bin/bash

mkdir build
cd build

if [[ "$target_platform" == osx-64 ]]; then
  export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake ${CMAKE_ARGS} ..
make -j${CPU_COUNT}
make install
