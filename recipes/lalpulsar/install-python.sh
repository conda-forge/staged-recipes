#!/bin/bash

set -e

. activate "${PREFIX}"

pushd ${SRC_DIR}

# configure only python bindings and pure-python extras
./configure \
	--prefix=$PREFIX \
	--disable-swig-iface \
	--enable-swig-python \
	--enable-python \
	--disable-doxygen \
	--disable-gcc-flags \
	--enable-silent-rules || { cat config.log; exit 1; }

# build
make -j ${CPU_COUNT} -C swig
make -j ${CPU_COUNT} -C python

# test
make -j ${CPU_COUNT} -C test check

# install
make -j ${CPU_COUNT} -C swig install-exec-am  # swig bindings
make -j ${CPU_COUNT} -C python install  # pure-python extras

popd
