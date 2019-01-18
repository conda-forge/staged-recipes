#!/bin/bash

export CXXFLAGS="-O2 -Wno-deprecated"

# mkdir -vp ${PREFIX}/bin;
mkdir build; cd build;
cmake $SRC_DIR \
	  -DUSE_FFMPEG=ON \
	  -DOIIO_BUILD_TOOLS=OFF \
	  -DOIIO_BUILD_TESTS=OFF \
	  -DUSE_PYTHON=OFF \
	  -DUSE_OPENCV=OFF \
	  -DCMAKE_INSTALL_PREFIX=$PREFIX \
	  -DCMAKE_SYSTEM_IGNORE_PATH=/usr/lib \
	  -DCMAKE_INSTALL_LIBDIR=lib

make install -j4
