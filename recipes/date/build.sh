#!/bin/bash

cmake ${CMAKE_ARGS} \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DUSE_SYSTEM_TZ_DB=ON \
      -DMANUAL_TZ_DB=OFF \
      -DUSE_TZ_DB_IN_DOT=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DENABLE_DATE_TESTING=OFF \
      -DDISABLE_STRING_VIEW=OFF \
      -DCOMPILE_WITH_C_LOCALE=OFF \
      -DBUILD_TZ_LIB=ON \
      $SRC_DIR

make install

