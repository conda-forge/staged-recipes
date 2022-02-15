#!/bin/bash

set -e
set -x

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

./configure --prefix="${PREFIX}" \ 
	    ${CONFIGURE_ARGS} 

make -j "${CPU_COUNT}" V=1 

# install and test the installation
make install V=1
make -j 8 check


# Build shared.
#cmake ${CMAKE_ARGS} \
#     -DCMAKE_INSTALL_PREFIX=${PREFIX} \
#     -DCMAKE_INSTALL_LIBDIR="lib" \
#     -DCMAKE_PREFIX_PATH=${PREFIX} \
#     -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
#     -DENABLE_HDF5=ON \
#     -DBUILD_SHARED_LIBS=ON \
#     -DENABLE_TESTS=ON \
#     ${SRC_DIR}

#make -j${CPU_COUNT} ${VERBOSE_CM}
#make install -j${CPU_COUNT} ${VERBOSE_CM}
#ctest -VV --output-on-failure -j${CPU_COUNT}

