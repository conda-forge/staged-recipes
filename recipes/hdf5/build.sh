#!/bin/bash

#if [ `uname -m` == ppc64le ]; then
#    B="--build=ppc64le-linux"
#fi

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE:STRING=RELEASE \
 -DCMAKE_PREFIX_PATH=$PREFIX \
 -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
 -DHDF5_BUILD_CPP_LIB=ON \
 -DBUILD_SHARED_LIBS:BOOL=ON \
 -DHDF5_BUILD_HL_LIB=ON \
 -DHDF5_BUILD_TOOLS:BOOL=ON \
 -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
 -DHDF5_BUILD_FRAMEWORKS=OFF $SRC_DIR

#./configure $B --prefix=$PREFIX --disable-static \
#    --enable-linux-lfs --with-zlib --with-ssl \
#    --with-pthread=yes  --enable-cxx --with-default-plugindir=$PREFIX/lib/hdf5/plugin

make
make install

rm -rf $PREFIX/share/hdf5_examples
