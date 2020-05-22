#!/bin/bash

./autogen.sh
./configure --disable-shared --enable-static \
            --disable-dependency-tracking --with-pic \
            --enable-module-recovery --disable-jni \
            --prefix $PREFIX --enable-experimental \
            --enable-module-ecdh --enable-benchmark=no \
            CC="${CC}" \
	CXX="${CXX}" \
            GCC="${GCC}" \
	CXXFLAGS="${CXXFLAGS} -O3" \
	LDFLAGS="${LDFLAGS}"

make -j ${CPU_COUNT}
make check -j ${CPU_COUNT}
make install
