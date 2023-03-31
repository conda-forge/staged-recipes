#!/usr/bin/env bash

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_TESTING=YES \
    -DCMAKE_BUILD_TYPE=Release \
    -DRANGES_ASSERTIONS=NO \
    -DRANGES_BUILD_CALENDAR_EXAMPLE=NO \
    -DRANGES_DEBUG_INFO=NO \
    -DRANGE_V3_DOCS=NO \
    -DRANGE_V3_EXAMPLES=NO \
    -DRANGE_V3_TESTS=YES \
    ..


make -j${CPU_COUNT} VERBOSE=1

ctest -j${CPU_COUNT} --output-on-failure

make install
