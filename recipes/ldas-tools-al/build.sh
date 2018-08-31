#!/bin/bash

./configure \
    CXXFLAGS="${CXXFLAGS} --std=c++14" \
    --prefix=${PREFIX} \
    --disable-tcl \
    --with-optimization=extreme \
    --without-doxygen
make -j ${CPU_COUNT}
make -j ${CPU_COUNT} check
make -j ${CPU_COUNT} install
