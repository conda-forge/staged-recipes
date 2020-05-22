#!/bin/bash

./autogen.sh
./configure --disable-shared --enable-static \
            --disable-dependency-tracking --with-pic \
            --enable-module-recovery --disable-jni \
            --prefix $PREFIX --enable-experimental \
            --enable-module-ecdh --enable-benchmark=no

make -j ${CPU_COUNT} CC=$CC GCC=$GCC CXX=$CXX
make check -j ${CPU_COUNT}
make install
