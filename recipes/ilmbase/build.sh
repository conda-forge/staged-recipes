#!/bin/bash

./configure --prefix=${PREFIX} \
            --host="${HOST}" \
            --build="${BUILD}" \
            --enable-cxxstd=11

make -j ${CPU_COUNT}
make install
