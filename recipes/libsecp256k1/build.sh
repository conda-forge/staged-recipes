#!/bin/bash

./autogen.sh
./configure --disable-shared --enable-static \
            --disable-dependency-tracking --with-pic \
            --enable-module-recovery --disable-jni \
            --prefix $PREFIX --enable-experimental \
            --enable-module-ecdh --enable-benchmark=no \
            CC_FOR_BUILD=${CC}
            CXX_FOR_BUILD=${CXX}

make -j ${CPU_COUNT}
make check -j ${CPU_COUNT}
make install
