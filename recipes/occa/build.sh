#!/usr/bin/env bash

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

export INSTALL_DIR=${PREFIX}
./configure-cmake.sh

cmake --build build -- -j$((CPU_COUNT))
cmake --build build --target install
