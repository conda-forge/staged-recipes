#!/bin/bash

set -e
set -x

# Get an updated config.sub and config.guess
cp ${BUILD_PREFIX}/share/gnuconfig/config.* .

./configure --prefix="${PREFIX}" \ 
	    ${CONFIGURE_ARGS} 

make -j ${CPU_COUNT} V=1 

# install and test the installation
make -j ${CPU_COUNT} install V=1
make -j ${CPU_COUNT} check

# remove the static libraries
rm -f ${PREFIX}/lib/libtrexio.a
