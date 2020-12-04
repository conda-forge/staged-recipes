#!/bin/bash

rm -rf build

mkdir build; cd build

export CTEST_OUTPUT_ON_FAILURE=1

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX    \
      -G "Unix Makefiles"            \
      -DWITH_BOOST=OFF               \
      -DSOCI_CXX11=ON                \
      -DSOCI_LIBDIR=lib              \
      -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      -DSOCI_STATIC=OFF              \
      $SRC_DIR

make -j${CPU_COUNT}

if [[ $PKG_NAME == *"sqlite" || $PKG_NAME == *"core" ]]; then
	make check
fi
make install
