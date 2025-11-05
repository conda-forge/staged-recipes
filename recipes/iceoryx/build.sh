#!/bin/bash

export CMAKE_POLICY_VERSION_MINIMUM=4.0

mkdir build
cd build
cmake ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_TEST=ON \
  ../iceoryx_meta

make -j${CPU_COUNT}
make all_tests
make install
