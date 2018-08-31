#!/bin/bash

./configure \
    CXXFLAGS="${CXXFLAGS} --std=c++14" \
    --prefix=${PREFIX} \
    --disable-warnings-as-errors \
    --with-optimization=extreme \
    --without-doxygen \
    --without-boost-unit-test-framework
make -j ${CPU_COUNT}
make -j ${CPU_COUNT} check
make -j ${CPU_COUNT} install
