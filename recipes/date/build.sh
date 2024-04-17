#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    # `std::uncaught_exceptions` is used by `date.h`, and the 10.9 version is not sufficient.
    # See: https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

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

