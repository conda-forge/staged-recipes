#!/bin/bash

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX    \
      -G "Unix Makefiles"            \
      -DWITH_BOOST=OFF               \
      -DSOCI_CXX11=ON                \
      -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      $SRC_DIR

make install
