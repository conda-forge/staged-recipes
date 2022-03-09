#!/bin/bash

set -e
set -x

# Get an updated config.sub and config.guess
cp ${BUILD_PREFIX}/share/gnuconfig/config.* .

# Build shared.
cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_INSTALL_LIBDIR="lib" \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DENABLE_HDF5=ON \
      -DBUILD_SHARED_LIBS=ON \
      ${SRC_DIR}

make -j${CPU_COUNT} ${VERBOSE_CM}
make install
ctest -VV --output-on-failure -j${CPU_COUNT}

#./configure --prefix="${PREFIX}" \ 
#	    ${CONFIGURE_ARGS} 

#make -j ${CPU_COUNT} V=1 

## install and test the installation
#make -j ${CPU_COUNT} install V=1
#make -j ${CPU_COUNT} check

# remove the static libraries
#rm -f ${PREFIX}/lib/libtrexio.a
