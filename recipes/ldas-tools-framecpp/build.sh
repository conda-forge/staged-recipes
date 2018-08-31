#!/bin/bash

./configure \
    --prefix=${PREFIX} \
    --disable-warnings-as-errors \
    --with-optimization=high \
    --without-doxygen \
    --without-boost-unit-test-framework
make -j ${CPU_COUNT}
make -j ${CPU_COUNT} check
make -j ${CPU_COUNT} install
