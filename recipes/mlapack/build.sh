#!/bin/bash

./configure --prefix=/usr/local \
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
make install
