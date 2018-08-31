#!/bin/bash

./configure \
    --prefix=${PREFIX} \
    --with-optimization=high \
    --without-doxygen
make -j ${CPU_COUNT}
make -j ${CPU_COUNT} check
make -j ${CPU_COUNT} install
