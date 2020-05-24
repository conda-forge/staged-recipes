#!/bin/bash

set -x

./autogen.sh
./configure --disable-shared --enable-static \
            --disable-dependency-tracking --with-pic \
            --enable-module-recovery --disable-jni \
            --prefix $PREFIX --enable-experimental \
            --enable-module-ecdh --enable-benchmark=no \
            CC_FOR_BUILD="${CC}" CPP_FOR_BUILD=${CPP} CXX="${CXX}" GCC="${GCC}" CXXFLAGS="${CXXFLAGS} -O3" LDFLAGS="${LDFLAGS}" 

make -j ${CPU_COUNT}
make check -j ${CPU_COUNT}
make install
