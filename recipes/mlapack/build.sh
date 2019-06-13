#!/bin/bash

# set C++ standard to gnu include gnu extensions, since the source code
# relies on these extensions
export CXXFLAGS=${CXXFLAGS/-std=c++17/-std=gnu++17}

autoreconf -i \
&& \
./configure --prefix=$PREFIX \
            --enable-gmp \
            --enable-mpfr \
            --enable-qd \
            --enable-dd \
            --enable-double \
            --enable-__float128 \
            --enable-longdouble \
            --enable-optimization \
            --disable-benchmark \
            --disable-examples \
            --disable-reference \
            --with-system-gmp \
            --with-system-mpfr \
            --with-system-mpc \
            --with-system-qd \
&& \
make -j ${CPU_COUNT} \
&& \
make check \
&& \
make install
