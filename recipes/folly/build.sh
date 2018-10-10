#!/bin/bash

export PREFIX=$CONDA_PREFIX
export LIBGFLAGS_INCLUDE_DIR=$PREFIX/include

if [ $(uname) == Darwin ]; then
  export CC=clang
  export CXX=clang++
  export MACOSX_DEPLOYMENT_TARGET="10.9"
  export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
  export CXXFLAGS="-I$PREFIX/include $CXXFLAGS"
  export LDFLAGS="-L$PREFIX/lib $LDFLAGS -Wl,-rpath,$PREFIX/lib"

  # export flags
  export OPENSSL_LIBS=-L${PREFIX}/lib
  export OPENSSL_CFLAGS=-I${PREFIX}/include
  export OPENSSL_INCLUDES=-I${PREFIX}/include
  export GFLAGS_LIBS=-L${PREFIX}/lib
  export GFLAGS_CFLAGS=-I${PREFIX}/include
  export GFLOG_LIBS=-L${PREFIX}/lib
  export GFLOG_CFLAGS=-I${PREFIX}/include

else
  export CC=$GCC
  export LD_LIBRARY_PATH=$BUILD_PREFIX/lib:$BUILD_PREFIX/lib64

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
