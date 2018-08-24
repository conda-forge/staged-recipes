#!/bin/bash

export LIBGFLAGS_INCLUDE_DIR=$PREFIX/include

if [ $(uname) == Darwin ]; then
  export CC=clang
  export CXX=clang++
  export MACOSX_DEPLOYMENT_TARGET="10.9"
  # export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
  export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

  # export flags
  export LDFLAGS="$LDFLAGS -L$PREFIX/lib -L${PREFIX}/lib/openssl"
  export OPENSSL_LIBS=-I${PREFIX}/lib/openssl
  export OPENSSL_CFLAGS=-I${PREFIX}/include/openssl
  export OPENSSL_INCLUDES=-I${PREFIX}/include/openssl
  export GFLAGS_LIBS=-L${PREFIX}/lib/gflags
  export GFLAGS_CFLAGS=-I${PREFIX}/include/gflags
  export GFLOG_LIBS=-L${PREFIX}/lib/glog
  export GFLOG_CFLAGS=-I${PREFIX}/include/glog

else
  export CC=$GCC
  export LD_LIBRARY_PATH=$BUILD_PREFIX/lib:$BUILD_PREFIX/lib64

  # export OPENSSL_LDFLAGS=$BUILD_PREFIX/bin
  # export OPENSSL_LIBS=-L$BUILD_PREFIX/lib
  # export OPENSSL_INCLUDES=-I$BUILD_PREFIX/include/openssl

  export PKG_CONFIG_PATH=$BUILD_PREFIX/lib/pkgconfig

  export CPPFLAGS="-std=c++14 -I$PREFIX/include $CPPFLAGS"
  export CXXFLAGS="-std=c++14 $CXXFLAGS"
  export LDFLAGS="$LDFLAGS -L$PREFIX/lib -L$PREFIX/lib64"
fi

cd folly

autoreconf -ivf

./configure \
   --prefix=$PREFIX \
   --with-boost=$PREFIX \
   --disable-silent-rules --disable-dependency-tracking

make
make install
