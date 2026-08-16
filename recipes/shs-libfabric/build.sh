#!/bin/bash

set -ex

autoreconf -ivf

./configure --prefix=${PREFIX} \
            --enable-cxi \
	    --with-cassini-headers=${PREFIX} \
            --with-cxi-uapi-headers=${PREFIX} \
            --with-curl=${PREFIX} \
            --with-json-c=${PREFIX} \
            --with-libnl=${PREFIX} \
            --docdir=$PWD/noinst/doc \
            --mandir=$PWD/noinst/man \
            --disable-lpp \
            --disable-psm3 \
            --disable-opx \
	    --disable-static

make -j${CPU_COUNT} src/libfabric.la
make -j${CPU_COUNT} util/fi_info util/fi_pingpong util/fi_strerror util/fi_mon_sampler

make install-exec install-data
